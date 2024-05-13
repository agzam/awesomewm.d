(local awful (require :awful))
(local gears (require :gears))
(local { : shellout
         : all-clients} (require :core))

(fn init []
  (let [cmd (string.format
             "emacsclient -e '(load-file \"%s\")'"
             (.. cfg_dir "lib/awesome-wm-helpers.el"))]
    (awful.spawn.with_shell cmd)))

(fn copy-to-clipboard [cb]
  (let [clb (shellout "xsel -ob")
        pri (shellout "xsel -op")]
    (when (or (= pri clb) (empty? pri))
      (awful.spawn.with_shell
       "xdotool key --clearmodifiers ctrl+a"))
    (awful.spawn.easy_async_with_shell
     "xdotool key --clearmodifiers ctrl+c"
     cb)))

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

(init)


;; (local coroutine (require :coroutine))

;; (fn get-apps []
;;   (menu-gen.generate (fn [x] (awesome.emit_signal "emacs::list-of-apps" x)))
;;   (awesome.connect_signal
;;    "emacs::list-of-apps"
;;    (fn [apps]
;;      (lame_dbg apps))))


;; (fn my-async-fn [cb]
;;   (let [co (coroutine.create (fn []
;;                                ))]
;;    (menu-gen.generate
;;     (fn [x]
;;       (cb x)))))

;; (fn my-async-fn [cb]
;;   (menu-gen.generate
;;    (fn [x]
;;      (gears.times
;;       {:autostart true
;;        :call_now true
;;        :timeout 0.1
;;        :calback (fn [] (cb x))}))))


;; (fn get-apps []
;;   (var val nil)
;;   (var co (coroutine.create (fn []
;;                               (awesome.connect_signal "emacs::list-of-apps" (fn [apps] (set val apps)))
;;                               (menu-gen.generate
;;                                (fn [x]
;;                                  (awesome.emit_signal "emacs::list-of-apps" x))))))
;;   (coroutine.resume co)
;;   (while (not val)
;;     (os.execute "sleep 0.1")
;;     (lame_dbg val))
;;   (lame_dbg "finally" val))

(local debug (require :gears.debug))

(local menu-gen (require :menubar.menu_gen))

(fn get_apps []
  (menu-gen.generate
   (fn [x] (set _G.list_of_apps x)))
  "one two three")

(get_apps)

{
 : edit-with-emacs
 : switch_to_client_and_paste
 : switch_to_app
 : get_apps
 : switch_to_prev_app_and_type
 }
