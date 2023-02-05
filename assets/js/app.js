// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "./loading_topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// channels connect
let pageId = null;

const urlRegex = /(.*:)\/\/([A-Za-z0-9\-\.]+)(:[0-9]+)?\/([^\/]*)\/?/;
const result = window.location.href.match(urlRegex);
if(result != null){
    pageId = result[4];
}else{
    //TODO: redirect
}

let socket = new Socket("/socket", { params: { _csrf_token: csrfToken, page_id: pageId } })
socket.connect()
window.socket = socket;

const updateLastTimeComponent = () => {
    document.querySelector("#last_update_timediff").innerHTML = `${window.lastUpdateTotalSeconds} seconds ago`;
    document.querySelector("#last_update_timediff").parentElement.classList = [];
}

const registerUpdateLastTimeInterval = () => {
    if(window.currentInterval !== undefined){
        clearInterval(window.currentInterval);
    }
    window.currentInterval = setInterval(() => {
        window.lastUpdateTotalSeconds += 1;
        updateLastTimeComponent();
    }, 1000.0);

    console.log(window.currentInterval, window.lastUpdateTotalSeconds);
}

const updateTimeDiff = () => {
    window.lastUpdateTotalSeconds = 0;
    updateLastTimeComponent();
    registerUpdateLastTimeInterval();
}

const channelId = `text_data:${pageId}`;
let channel = socket.channel(channelId)
channel.join()
    .receive("ok", resp => { console.log(`Joined "${channelId}" successfully`) })
    .receive("error", resp => { console.log("Unable to join", resp) });

channel.on("update", (message) => {
    console.log(`[socket@text_data:${pageId}/update -- RECV: ${message}`);
    document.querySelector("#text_data").value = message.value;
    updateTimeDiff();
})

channel.on(`number_online`, (message) => {
    console.log(`[socket@text_data:${pageId}/number_online -- RECV: ${JSON.stringify(message)}`);
    if(message.number_online == 1){
        document.querySelector("#online_counter").innerHTML = " Just you"

    }else{
        document.querySelector("#online_counter").innerHTML = message.number_online;
    }
})

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

let timerDebounceTextDataInput;
function debounceTextDataInput(func, millis = 500) {

    return (...args) => {
        clearTimeout(timerDebounceTextDataInput);
        timerDebounceTextDataInput = setTimeout(() => { func.apply(this, args); }, millis);
    };
}

document.addEventListener("DOMContentLoaded", () => {

    registerUpdateLastTimeInterval();

    const textDataInputDOM = document.querySelector("#text_data");
    textDataInputDOM ? textDataInputDOM.addEventListener("input", (event) => {
        debounceTextDataInput((newValue) => {
            const payload = {value: newValue};
            console.log(`[socket@text_data:murilo/change -- PUSH: ${JSON.stringify(payload)}`);
            channel.push("change", payload);
            updateTimeDiff();
        }, 200)(event.currentTarget.value);
    }):"";

    window.addEventListener("beforeunload", () => {
        channel.leave();
    })

});