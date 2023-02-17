const urlRegex = /(.*:)\/\/([A-Za-z0-9\-\.]+)(:[0-9]+)?\/([^\/]*)\/?/;
export default function getPage() {
    const result = window.location.href.match(urlRegex);
    if (result != null) {
        return result[4];
    }
    throw new Error("Page not found");
}