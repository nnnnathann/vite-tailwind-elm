/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_MY_API_URL: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
