(local awful (require :awful))
(local gears (require :gears))
(local { : shellout
         : executable-find
         : all-clients} (require :core))

(fn init []
  (let [cmd (string.format
             "emacsclient -e '(load-file \"%s\")'"
             (.. cfg_dir "lib/awesome-wm-helpers.el"))]
    (awful.spawn.with_shell cmd)))

(fn copy-to-clipboard [cb]
  (let [xsel (executable-find "xsel")
        _ (shellout (.. xsel " --clipboard --clear"))
        ;; clb (shellout (.. xsel " -ob"))
        pri (shellout (.. xsel " -op"))]
    (when (empty? pri)
      (awful.spawn.with_shell
       "xdotool key --clearmodifiers ctrl+a"))
    (awful.spawn.easy_async_with_shell
     "xdotool key --clearmodifiers ctrl+c"
     cb)
    (shellout (.. xsel " --primary --clear"))))

(fn edit-with-emacs []
  (init)
  (when (and client.focus
             (not= client.focus.class :Emacs))
    (copy-to-clipboard
     (fn []
       (let [cmd (string.format
                  "emacsclient -e '(awesome-edit-with-emacs %s \"%s\")' &"
                  client.focus.pid
                  (gears.string.xml_escape
                   client.focus.name))
             emacs-cl (-?>> (all-clients)
                            (filter (fn [c] (= c.class :Emacs)))
                            first)]
         (awful.spawn.with_shell cmd)
         (awful.client.focus.byidx 0 emacs-cl))))))

(fn switch_to_app [pid cb]
  (let [app-cl (-?>> (all-clients)
                     (filter (fn [c] (= c.pid pid)))
                     first)]
    (awful.client.focus.byidx 0 app-cl)
    (when client.focus
      (cb))))

(fn switch_to_client_and_paste [pid]
  (switch_to_app
   pid
   (fn []
     (when client.focus
       (awful.spawn.with_shell "xdotool key ctrl+v")))))

(fn switch_to_prev_app_and_type [text]
  "Find previously focused app and type given text.
Useful for sending text from Emacs to text input of the app."
  (awful.client.focus.byidx -1)
  (gears.timer.weak_start_new
   0.05
   (fn []
     (when client.focus
       (awful.spawn.with_shell
        (string.format "xdotool type --clearmodifiers '%s'" text)))
     false)))

(fn browse-url-with-emacs [url]
  (when (starts-with? url "http")
    (let [cmd (string.format "emacsclient -e '(+process-external-url \"%s\")'" url)
          emacs-cl (-?>> (all-clients)
                         (filter (fn [c] (= c.class :Emacs)))
                         first)]
      (awful.spawn.with_shell cmd)
      (awful.client.focus.byidx 0 emacs-cl))))

(init)

{
 : edit-with-emacs
 : switch_to_client_and_paste
 : switch_to_app
 : switch_to_prev_app_and_type
 : browse-url-with-emacs
 }
