import axios from "axios";

export const axiosInstance = axios.create({
  baseURL: "http://localhost:4000/api/v1/",
});

axiosInstance.interceptors.request.use(
  function (config) {
    if (localStorage.getItem("token")) {
      config.headers["Authorization"] = localStorage.getItem("token");
    }
    return config;
  },
  function (error) {
    return Promise.reject(error);
  }
);
