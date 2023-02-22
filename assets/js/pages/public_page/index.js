import { pushTextareaChange } from "./channel";
import domSelector from "./dom_selectors";
import { debounceTextDataInput, fileDeleteRequest, registerFileListEvents, registerUpdateLastTimeInterval, updateTimeDiff } from "./helpers";
import { getUrls, setLastUpdateTotalSeconds, setUrls } from "./page_data";

/*
JAVASCRIPT window exports
*/

function loadPublicPageModule(_lastUpdateTotalSeconds, _urls) {

    setLastUpdateTotalSeconds(_lastUpdateTotalSeconds);
    setUrls(_urls);

    registerUpdateLastTimeInterval();
    registerFileListEvents();

    domSelector.uploadForm().addEventListener("submit", (event) => {
        event.preventDefault();

        const url = getUrls().uploadFile;
        const formData = new FormData(event.target);

        const response = fetch(url, {
            method: "post",
            body: formData
        });

        response.then(resp => {
            console.log("uploaded file")
        })
    });

    domSelector.textarea().addEventListener("input", (event) => {
        debounceTextDataInput((newValue) => {
            pushTextareaChange(newValue);
            updateTimeDiff();
        }, 200)(event.currentTarget.value);
    });

    window.addEventListener("beforeunload", () => {
        channel.leave();
    })

}

const runExports = () => {
    window.loadPublicPageModule = loadPublicPageModule;
}

export default {
    runExports
}