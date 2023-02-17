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

const downloadFileRowList = () => {
    return document.querySelectorAll(".downloadFile");
}

const deleteFileButtonList = () => {
    return document.querySelectorAll(".deleteFile");
}

export default {
    lastUpdateTimediffSpan,
    textarea,
    onlineCounter,
    uploadForm,
    downloadFileRowList,
    deleteFileButtonList
}