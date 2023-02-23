const lastUpdateTimediffSpan = () => {
    return document.querySelector("#last_update_timediff");
}

const textarea = () => {
    return document.querySelector("#text_data");
}

const onlineCounter = () => {
    return document.querySelector("#online_counter");
}

const uploadForm = () => {
    return document.querySelector("#form_upload");
}

const uploadFileInput = () => {
    return uploadForm().querySelector("input[type=file]")
}

const downloadFileRowList = () => {
    return document.querySelectorAll(".downloadFile");
}

const deleteFileButtonList = () => {
    return document.querySelectorAll(".deleteFile");
}

const fileListRoot = () => {
    return document.querySelector("#file_list");
}

const uploadStatusList = () => {
    return document.querySelector("#upload_status");
}

const uploadStatusRow = (id) => {
    return document.querySelector("#upload_status").querySelector(`li[file-idx='${id}']`);
}

const statusProgressContainer = (id) => {
    return uploadStatusRow(id).querySelector(".uploadStatus");
}

const statusProgressBar = (id) => {
    return statusProgressContainer(id).children[0];
}

export default {
    lastUpdateTimediffSpan,
    textarea,
    onlineCounter,
    uploadForm,
    downloadFileRowList,
    deleteFileButtonList,
    fileListRoot,
    uploadFileInput,
    uploadStatusList,
    uploadStatusRow,
    statusProgressContainer,
    statusProgressBar
}