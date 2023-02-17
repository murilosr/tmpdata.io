import { Socket } from "phoenix";
import { getTopic, updateTimeDiff } from "./helpers";
import getPage from "../../libs/get_page";
import getCsrfToken from "../../libs/get_csrf_token";
import domSelector from "./dom_selectors";

let socket = new Socket("/socket", { params: { _csrf_token: getCsrfToken(), page_id: getPage() } });
socket.connect();

function logChannel(event, message, recv = true){
    console.log(`[socket@${getTopic()} - (${event}) - ${recv?"RECV":"SEND"}: ${message}`);
}

/*
Channel creation & event handlers
*/

const channel = socket.channel(getTopic());

channel.join()
    .receive("ok", resp => { console.log(`Joined "${getTopic()}" successfully`) })
    .receive("error", resp => { console.log("Unable to join", resp) });

channel.on("update", (message) => {
    logChannel("update", JSON.stringify(message));
    domSelector.textarea().value = message.value;
    updateTimeDiff();
})

channel.on(`number_online`, (message) => {
    logChannel("update", JSON.stringify(message));
    if (message.number_online == 1) {
        domSelector.onlineCounter().innerHTML = " Just you"
    } else {
        domSelector.onlineCounter().innerHTML = message.number_online;
    }
})

/*
Channel pushes
*/

const pushTextareaChange = (newValue) => {
    const payload = { value: newValue };
    logChannel("change", JSON.stringify(payload), false);
    channel.push("change", payload);
}

export {
    socket,
    pushTextareaChange
}