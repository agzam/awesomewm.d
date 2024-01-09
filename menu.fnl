(local awful (require :awful))
(local hotkeys_popup (require :awful.hotkeys_popup))

(local menubar (require :menubar))
(local terminal :kitty)
(set menubar.utils.terminal terminal)

(fn quit []
  (let [confirm-dlg (awful.menu {:items [[:cancel (fn [] nil)]
                                         [:quit (fn [] (awesome.quit))]]})]
    (confirm-dlg:show)))

(local my_awesome_menu
       [[:hotkeys
         (fn []
           (hotkeys_popup.show_help nil (awful.screen.focused)))]
        [:manual (.. terminal " -e man awesome")]
        ;; ["edit config" (.. editor_cmd " " awesome.conffile)]
        [:restart awesome.restart]
        [:run
         (fn []
           (-?> (awful.screen.focused)
                (. :my_promptbox)
                (: :run)))]
        [:quit quit]])

(local my_main_menu (awful.menu {:items my_awesome_menu}))

{: my_main_menu}
