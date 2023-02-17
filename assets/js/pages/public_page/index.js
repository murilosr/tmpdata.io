import { pushTextareaChange } from "./channel";
import domSelector from "./dom_selectors";
import { debounceTextDataInput, fileDeleteRequest, registerUpdateLastTimeInterval, updateTimeDiff } from "./helpers";
import { getUrls, setLastUpdateTotalSeconds, setUrls } from "./page_data";

/*
JAVASCRIPT window exports
*/

function loadPublicPageModule(_lastUpdateTotalSeconds, _urls) {

    setLastUpdateTotalSeconds(_lastUpdateTotalSeconds);
    setUrls(_urls);

    registerUpdateLastTimeInterval();

    domSelector.deleteFileButtonList().forEach(el => {
        el.addEventListener("click", (event) => {
            event.stopPropagation();
            const target = event.currentTarget;
            const fileId = target.parentNode.getAttribute("file-id");

            fileDeleteRequest(getUrls().deleteFile, fileId);
        })
    });

    domSelector.downloadFileRowList().forEach(el => {
        el.addEventListener("click", (event) => {
            const target = event.currentTarget;
            const fileId = target.getAttribute("file-id");
            const fileName = target.getAttribute("file-name");

            window.open(getUrls().downloadFile.replace("FILE_ID", fileId).replace("FILE_NAME", fileName));
        })
    });

    domSelector.uploadForm().addEventListener("submit", (event) => {
        event.preventDefault();

        const url = getUrls().uploadFile;
        const formData = new FormData(event.target);

        const response = fetch(url, {
            method: "post",
            body: formData
        });

        response.then(resp => {
            location.reload();
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