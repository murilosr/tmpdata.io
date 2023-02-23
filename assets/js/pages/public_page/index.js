import { pushTextareaChange } from "./channel";
import domSelector from "./dom_selectors";
import { addCompleteStatus, addUploadStatusRow, debounceTextDataInput, registerFileInputEvents, registerFileListEvents, registerUpdateLastTimeInterval, updateTimeDiff } from "./helpers";
import { getUrls, setLastUpdateTotalSeconds, setUrls } from "./page_data";

/*
JAVASCRIPT window exports
*/

let uploadFileIdx = 0;

function loadPublicPageModule(_lastUpdateTotalSeconds, _urls) {

    setLastUpdateTotalSeconds(_lastUpdateTotalSeconds);
    setUrls(_urls);

    registerUpdateLastTimeInterval();
    registerFileListEvents();
    registerFileInputEvents();

    domSelector.uploadForm().addEventListener("submit", (event) => {
        event.preventDefault();

        const url = getUrls().uploadFile;
        const formData = new FormData(event.target);

        domSelector.uploadFileInput().value = "";
        const filename = formData.get("upload_file").name;
        const filesize = formData.get("upload_file").size;
        const fileId = uploadFileIdx;
        uploadFileIdx += 1;

        addUploadStatusRow(fileId, filename, filesize);

        let request = new XMLHttpRequest();
        // Ensure the request method is POST
        request.open('POST', url);
        // Attach the progress event handler to the AJAX request
        request.upload.addEventListener('progress', function(event) {
            const progress = ((event.loaded/event.total)*100).toFixed(0);
            domSelector.statusProgressBar(fileId).style.width = progress > 98 ? '98%':progress + '%';
        });
        // The following code will execute when the request is complete
        request.onreadystatechange = () => {
            if (request.readyState == 4 && request.status == 200) {
                domSelector.statusProgressBar(fileId).style.width = '100%';
                addCompleteStatus(fileId);
            }
        };
        // Execute request
        request.send(formData);
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