import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import englishMessages from "./messages/en/englishMessages";
import persianMessages from "./messages/fa/persianMessages";

i18n.use(initReactI18next).init({
  lng: "fa",
  fallbackLng: "en",
  resources: {
    en: { translation: englishMessages },
    fa: { translation: persianMessages },
  },
});

export default i18n;
