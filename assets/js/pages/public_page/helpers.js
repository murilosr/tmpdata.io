import getPage from "../../libs/get_page";
import domSelector from "./dom_selectors";
import { getTimerDebounceTextDataInput, getUrls, setTimerDebounceTextDataInput } from "./page_data";
import { getActiveInterval, getLastUpdateTotalSeconds, setActiveInterval, setLastUpdateTotalSeconds } from "./page_data";

const getTopic = () => {
    return `text_data:${getPage()}`
}

const getFileSize = (filesize) => {
    mb = Math.fround(filesize / 1.0e6, 2).toFixed(2);
    kb = Math.fround(filesize / 1.0e3, 2).toFixed(2);

    if(kb < 1.0) return `${filesize} B`;
    if(mb < 1.0) return `${kb} KB`;
    return `${mb} MB`;
}

function debounceTextDataInput(func, millis = 500) {
    return (...args) => {
        clearTimeout(getTimerDebounceTextDataInput());
        const newTimeout = setTimeout(() => { func.apply(this, args); }, millis);
        setTimerDebounceTextDataInput(newTimeout);
    };
}

async function fileDeleteRequest(delete_path, fileId){
    const url = delete_path.replace("FILE_ID", fileId);
    const response = await fetch(url, {
        method: "delete",
        headers: {"Content-Type": "application/json"}
    });
}

const updateLastTimeComponent = () => {
    domSelector.lastUpdateTimediffSpan().innerHTML = `${getLastUpdateTotalSeconds()} seconds ago`;
    domSelector.lastUpdateTimediffSpan().parentElement.classList = [];
}

const registerUpdateLastTimeInterval = () => {
    let activeInterval = getActiveInterval();
    if (activeInterval !== undefined) {
        clearInterval(activeInterval);
    }
    activeInterval = setInterval(() => {
        const lastUpdateTotalSeconds = getLastUpdateTotalSeconds();
        if (lastUpdateTotalSeconds !== undefined) {
            setLastUpdateTotalSeconds(lastUpdateTotalSeconds + 1);
            updateLastTimeComponent();
        };
    }, 1000.0);
    setActiveInterval(activeInterval);
}

const updateTimeDiff = () => {
    setLastUpdateTotalSeconds(0);
    updateLastTimeComponent();
    registerUpdateLastTimeInterval();
}

const registerFileListEvents = () => {

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

}

const registerFileInputEvents = () => {

    domSelector.uploadFileInput().addEventListener("change", () => {
        domSelector.uploadForm().dispatchEvent(new Event("submit"));
    });

}

const addUploadStatusRow = (id, filename, filesize) => {
    domSelector.uploadStatusList().parentElement.classList.remove("hidden");

    const statusRow = document.createElement("li");
    statusRow.setAttribute("file-idx", id);
    statusRow.innerHTML = `
    <div class="flex">
        <span class="flex-1 mr-4">${filename}</span>
        <span>${getFileSize(filesize)}</span>
    </div>
    <div class="uploadStatus flex-1 h-2 rounded-lg border overflow-clip relative">
        <div class="h-4 bg-blue-300 rounded-lg" style="width: 50%" />
    </div>
    `;
    statusRow.className = "flex px-4 py-4 flex-col w-full border-b last:border-b-0 break-all"

    domSelector.uploadStatusList().appendChild(statusRow);
}

const addCompleteStatus = (id) => {
    const completeProgressBar = document.createElement("div");
    completeProgressBar.className = "complete w-0";

    domSelector.statusProgressContainer(id).appendChild(completeProgressBar);
    // Trick to trigger the width transition
    // Found solution at: https://stackoverflow.com/questions/24148403/trigger-css-transition-on-appended-element
    completeProgressBar.offsetWidth;

    domSelector.statusProgressContainer(id).children[1].classList.remove("w-0");
    domSelector.statusProgressContainer(id).children[1].classList.add("w-full");
    completeProgressBar.offsetWidth;

    setTimeout(() => {
        hideUploadStatusRow(id);
    }, 3000);

}

const hideUploadStatusSectionIfNeeded = () => {
    if(domSelector.uploadStatusList().children.length === 0)
        domSelector.uploadStatusList().parentElement.classList.add("hidden");
}

const hideUploadStatusRow = (id) => {
    domSelector.uploadStatusRow(id).style.maxHeight = "0px";
    domSelector.uploadStatusRow(id).classList.remove("py-4");
    domSelector.uploadStatusRow(id).classList.add("overflow-clip");
    domSelector.uploadStatusRow(id).offsetHeight;

    setTimeout(() => {
        domSelector.uploadStatusRow(id).parentElement.removeChild(domSelector.uploadStatusRow(id));
        hideUploadStatusSectionIfNeeded();
    }, 800);
}

window.addCompleteStatus = addCompleteStatus;

export {
    getTopic,
    getFileSize,
    fileDeleteRequest,
    debounceTextDataInput,
    updateLastTimeComponent,
    registerUpdateLastTimeInterval,
    updateTimeDiff,
    registerFileListEvents,
    registerFileInputEvents,
    addUploadStatusRow,
    addCompleteStatus
}