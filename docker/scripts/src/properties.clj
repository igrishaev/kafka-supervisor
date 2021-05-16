(ns properties
  "
  A small script to saturate a .property file
  with environment variables filtered by a prefix.
  "
  (:gen-class)
  (:require
   [clojure.java.io :as io]
   [clojure.string :as str])
  (:import java.util.Properties))


(defn exit [code template & args]
  (let [out (if (zero? code) *out* *err*)]
    (binding [*out* out]
      (println (apply format template args))))
  (System/exit code))


(defn get-env-map []
  (into {} (System/getenv)))


(defn ->prop-name
  "
  Turn an environment name into a property name.
  "
  [env-name]
  (-> env-name
      (str/lower-case)
      (str/trim)
      (str/replace #"_+" ".")))


(defn rewrite-config [env-prefix file-path]

  (let [props (new Properties)
        env (get-env-map)
        prefix-len (count env-prefix)]

    (.load props (io/reader file-path))

    (doseq [[env-name env-val] env]

      (when (str/starts-with? env-name env-prefix)
        (let [env-rest (subs env-name prefix-len) ;; drop prefix
              prop-name (->prop-name env-rest)]
          (.setProperty props prop-name env-val))))

    (.store props (io/writer file-path) nil)))


(defn -main
  [& [env-prefix props-path]]

  (when-not env-prefix
    (exit 1 "ENV prefix not set"))

  (when-not props-path
    (exit 1 ".property path not set"))

  (rewrite-config env-prefix props-path)

  (exit 0
        "Config rewritten, prefix: %s, path: %s"
        env-prefix props-path))
