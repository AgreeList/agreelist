import axios from 'axios';
var AxiosHelper = function () {
    var csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
    axios.defaults.headers.common['X-CSRF-TOKEN'] = csrfToken;
};
export default AxiosHelper;
//# sourceMappingURL=AxiosHelper.js.map