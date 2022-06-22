#include <GWA2.au3>

Global Const $bs_groupbox = 7
Global Const $bs_bottom = 2048
Global Const $bs_center = 768
Global Const $bs_defpushbutton = 1
Global Const $bs_left = 256
Global Const $bs_multiline = 8192
Global Const $bs_pushbox = 10
Global Const $bs_pushlike = 4096
Global Const $bs_right = 512
Global Const $bs_rightbutton = 32
Global Const $bs_top = 1024
Global Const $bs_vcenter = 3072
Global Const $bs_flat = 32768
Global Const $bs_icon = 64
Global Const $bs_bitmap = 128
Global Const $bs_notify = 16384
Global Const $bs_splitbutton = 12
Global Const $bs_defsplitbutton = 13
Global Const $bs_commandlink = 14
Global Const $bs_defcommandlink = 15
Global Const $bcsif_glyph = 1
Global Const $bcsif_image = 2
Global Const $bcsif_style = 4
Global Const $bcsif_size = 8
Global Const $bcss_nosplit = 1
Global Const $bcss_stretch = 2
Global Const $bcss_alignleft = 4
Global Const $bcss_image = 8
Global Const $button_imagelist_align_left = 0
Global Const $button_imagelist_align_right = 1
Global Const $button_imagelist_align_top = 2
Global Const $button_imagelist_align_bottom = 3
Global Const $button_imagelist_align_center = 4
Global Const $bs_3state = 5
Global Const $bs_auto3state = 6
Global Const $bs_autocheckbox = 3
Global Const $bs_checkbox = 2
Global Const $bs_radiobutton = 4
Global Const $bs_autoradiobutton = 9
Global Const $bs_ownerdraw = 11
Global Const $gui_ss_default_button = 0
Global Const $gui_ss_default_checkbox = 0
Global Const $gui_ss_default_group = 0
Global Const $gui_ss_default_radio = 0
Global Const $bcm_first = 5632
Global Const $bcm_getidealsize = ($bcm_first + 1)
Global Const $bcm_getimagelist = ($bcm_first + 3)
Global Const $bcm_getnote = ($bcm_first + 10)
Global Const $bcm_getnotelength = ($bcm_first + 11)
Global Const $bcm_getsplitinfo = ($bcm_first + 8)
Global Const $bcm_gettextmargin = ($bcm_first + 5)
Global Const $bcm_setdropdownstate = ($bcm_first + 6)
Global Const $bcm_setimagelist = ($bcm_first + 2)
Global Const $bcm_setnote = ($bcm_first + 9)
Global Const $bcm_setshield = ($bcm_first + 12)
Global Const $bcm_setsplitinfo = ($bcm_first + 7)
Global Const $bcm_settextmargin = ($bcm_first + 4)
Global Const $bm_click = 245
Global Const $bm_getcheck = 240
Global Const $bm_getimage = 246
Global Const $bm_getstate = 242
Global Const $bm_setcheck = 241
Global Const $bm_setdontclick = 248
Global Const $bm_setimage = 247
Global Const $bm_setstate = 243
Global Const $bm_setstyle = 244
Global Const $bcn_first = -1250
Global Const $bcn_dropdown = ($bcn_first + 2)
Global Const $bcn_hotitemchange = ($bcn_first + 1)
Global Const $bn_clicked = 0
Global Const $bn_paint = 1
Global Const $bn_hilite = 2
Global Const $bn_unhilite = 3
Global Const $bn_disable = 4
Global Const $bn_doubleclicked = 5
Global Const $bn_setfocus = 6
Global Const $bn_killfocus = 7
Global Const $bn_pushed = $bn_hilite
Global Const $bn_unpushed = $bn_unhilite
Global Const $bn_dblclk = $bn_doubleclicked
Global Const $bst_checked = 1
Global Const $bst_indeterminate = 2
Global Const $bst_unchecked = 0
Global Const $bst_focus = 8
Global Const $bst_pushed = 4
Global Const $bst_dontclick = 128
Global Const $cb_err = -1
Global Const $cb_errattribute = -3
Global Const $cb_errrequired = -4
Global Const $cb_errspace = -2
Global Const $cb_okay = 0
Global Const $state_system_invisible = 32768
Global Const $state_system_pressed = 8
Global Const $cbs_autohscroll = 64
Global Const $cbs_disablenoscroll = 2048
Global Const $cbs_dropdown = 2
Global Const $cbs_dropdownlist = 3
Global Const $cbs_hasstrings = 512
Global Const $cbs_lowercase = 16384
Global Const $cbs_nointegralheight = 1024
Global Const $cbs_oemconvert = 128
Global Const $cbs_ownerdrawfixed = 16
Global Const $cbs_ownerdrawvariable = 32
Global Const $cbs_simple = 1
Global Const $cbs_sort = 256
Global Const $cbs_uppercase = 8192
Global Const $cbm_first = 5888
Global Const $cb_addstring = 323
Global Const $cb_deletestring = 324
Global Const $cb_dir = 325
Global Const $cb_findstring = 332
Global Const $cb_findstringexact = 344
Global Const $cb_getcomboboxinfo = 356
Global Const $cb_getcount = 326
Global Const $cb_getcuebanner = ($cbm_first + 4)
Global Const $cb_getcursel = 327
Global Const $cb_getdroppedcontrolrect = 338
Global Const $cb_getdroppedstate = 343
Global Const $cb_getdroppedwidth = 351
Global Const $cb_geteditsel = 320
Global Const $cb_getextendedui = 342
Global Const $cb_gethorizontalextent = 349
Global Const $cb_getitemdata = 336
Global Const $cb_getitemheight = 340
Global Const $cb_getlbtext = 328
Global Const $cb_getlbtextlen = 329
Global Const $cb_getlocale = 346
Global Const $cb_getminvisible = 5890
Global Const $cb_gettopindex = 347
Global Const $cb_initstorage = 353
Global Const $cb_limittext = 321
Global Const $cb_resetcontent = 331
Global Const $cb_insertstring = 330
Global Const $cb_selectstring = 333
Global Const $cb_setcuebanner = ($cbm_first + 3)
Global Const $cb_setcursel = 334
Global Const $cb_setdroppedwidth = 352
Global Const $cb_seteditsel = 322
Global Const $cb_setextendedui = 341
Global Const $cb_sethorizontalextent = 350
Global Const $cb_setitemdata = 337
Global Const $cb_setitemheight = 339
Global Const $cb_setlocale = 345
Global Const $cb_setminvisible = 5889
Global Const $cb_settopindex = 348
Global Const $cb_showdropdown = 335
Global Const $cbn_closeup = 8
Global Const $cbn_dblclk = 2
Global Const $cbn_dropdown = 7
Global Const $cbn_editchange = 5
Global Const $cbn_editupdate = 6
Global Const $cbn_errspace = (-1)
Global Const $cbn_killfocus = 4
Global Const $cbn_selchange = 1
Global Const $cbn_selendcancel = 10
Global Const $cbn_selendok = 9
Global Const $cbn_setfocus = 3
Global Const $cbes_ex_casesensitive = 16
Global Const $cbes_ex_noeditimage = 1
Global Const $cbes_ex_noeditimageindent = 2
Global Const $cbes_ex_nosizelimit = 8
Global Const $__comboboxconstant_wm_user = 1024
Global Const $cbem_deleteitem = $cb_deletestring
Global Const $cbem_getcombocontrol = ($__comboboxconstant_wm_user + 6)
Global Const $cbem_geteditcontrol = ($__comboboxconstant_wm_user + 7)
Global Const $cbem_getexstyle = ($__comboboxconstant_wm_user + 9)
Global Const $cbem_getextendedstyle = ($__comboboxconstant_wm_user + 9)
Global Const $cbem_getimagelist = ($__comboboxconstant_wm_user + 3)
Global Const $cbem_getitema = ($__comboboxconstant_wm_user + 4)
Global Const $cbem_getitemw = ($__comboboxconstant_wm_user + 13)
Global Const $cbem_getunicodeformat = 8192 + 6
Global Const $cbem_haseditchanged = ($__comboboxconstant_wm_user + 10)
Global Const $cbem_insertitema = ($__comboboxconstant_wm_user + 1)
Global Const $cbem_insertitemw = ($__comboboxconstant_wm_user + 11)
Global Const $cbem_setexstyle = ($__comboboxconstant_wm_user + 8)
Global Const $cbem_setextendedstyle = ($__comboboxconstant_wm_user + 14)
Global Const $cbem_setimagelist = ($__comboboxconstant_wm_user + 2)
Global Const $cbem_setitema = ($__comboboxconstant_wm_user + 5)
Global Const $cbem_setitemw = ($__comboboxconstant_wm_user + 12)
Global Const $cbem_setunicodeformat = 8192 + 5
Global Const $cbem_setwindowtheme = 8192 + 11
Global Const $cben_first = (-800)
Global Const $cben_last = (-830)
Global Const $cben_beginedit = ($cben_first - 4)
Global Const $cben_deleteitem = ($cben_first - 2)
Global Const $cben_dragbegina = ($cben_first - 8)
Global Const $cben_dragbeginw = ($cben_first - 9)
Global Const $cben_endedita = ($cben_first - 5)
Global Const $cben_endeditw = ($cben_first - 6)
Global Const $cben_getdispinfo = ($cben_first + 0)
Global Const $cben_getdispinfoa = ($cben_first + 0)
Global Const $cben_getdispinfow = ($cben_first - 7)
Global Const $cben_insertitem = ($cben_first - 1)
Global Const $cbeif_di_setitem = 268435456
Global Const $cbeif_image = 2
Global Const $cbeif_indent = 16
Global Const $cbeif_lparam = 32
Global Const $cbeif_overlay = 8
Global Const $cbeif_selectedimage = 4
Global Const $cbeif_text = 1
Global Const $gui_ss_default_combo = 2097218
Global Const $gui_event_single = 0
Global Const $gui_event_array = 1
Global Const $gui_event_none = 0
Global Const $gui_event_close = -3
Global Const $gui_event_minimize = -4
Global Const $gui_event_restore = -5
Global Const $gui_event_maximize = -6
Global Const $gui_event_primarydown = -7
Global Const $gui_event_primaryup = -8
Global Const $gui_event_secondarydown = -9
Global Const $gui_event_secondaryup = -10
Global Const $gui_event_mousemove = -11
Global Const $gui_event_resized = -12
Global Const $gui_event_dropped = -13
Global Const $gui_rundefmsg = "GUI_RUNDEFMSG"
Global Const $gui_avistop = 0
Global Const $gui_avistart = 1
Global Const $gui_aviclose = 2
Global Const $gui_checked = 1
Global Const $gui_indeterminate = 2
Global Const $gui_unchecked = 4
Global Const $gui_dropaccepted = 8
Global Const $gui_nodropaccepted = 4096
Global Const $gui_acceptfiles = $gui_dropaccepted
Global Const $gui_show = 16
Global Const $gui_hide = 32
Global Const $gui_enable = 64
Global Const $gui_disable = 128
Global Const $gui_focus = 256
Global Const $gui_nofocus = 8192
Global Const $gui_defbutton = 512
Global Const $gui_expand = 1024
Global Const $gui_ontop = 2048
Global Const $gui_fontnormal = 0
Global Const $gui_fontitalic = 2
Global Const $gui_fontunder = 4
Global Const $gui_fontstrike = 8
Global Const $gui_dockauto = 1
Global Const $gui_dockleft = 2
Global Const $gui_dockright = 4
Global Const $gui_dockhcenter = 8
Global Const $gui_docktop = 32
Global Const $gui_dockbottom = 64
Global Const $gui_dockvcenter = 128
Global Const $gui_dockwidth = 256
Global Const $gui_dockheight = 512
Global Const $gui_docksize = 768
Global Const $gui_dockmenubar = 544
Global Const $gui_dockstatebar = 576
Global Const $gui_dockall = 802
Global Const $gui_dockborders = 102
Global Const $gui_gr_close = 1
Global Const $gui_gr_line = 2
Global Const $gui_gr_bezier = 4
Global Const $gui_gr_move = 6
Global Const $gui_gr_color = 8
Global Const $gui_gr_rect = 10
Global Const $gui_gr_ellipse = 12
Global Const $gui_gr_pie = 14
Global Const $gui_gr_dot = 16
Global Const $gui_gr_pixel = 18
Global Const $gui_gr_hint = 20
Global Const $gui_gr_refresh = 22
Global Const $gui_gr_pensize = 24
Global Const $gui_gr_nobkcolor = -2
Global Const $gui_bkcolor_default = -1
Global Const $gui_bkcolor_transparent = -2
Global Const $gui_bkcolor_lv_alternate = -33554432
Global Const $gui_read_default = 0
Global Const $gui_read_extended = 1
Global Const $gui_cursor_nooverride = 0
Global Const $gui_cursor_override = 1
Global Const $gui_ws_ex_parentdrag = 1048576
Global Const $ss_left = 0
Global Const $ss_center = 1
Global Const $ss_right = 2
Global Const $ss_icon = 3
Global Const $ss_blackrect = 4
Global Const $ss_grayrect = 5
Global Const $ss_whiterect = 6
Global Const $ss_blackframe = 7
Global Const $ss_grayframe = 8
Global Const $ss_whiteframe = 9
Global Const $ss_simple = 11
Global Const $ss_leftnowordwrap = 12
Global Const $ss_bitmap = 14
Global Const $ss_enhmetafile = 15
Global Const $ss_etchedhorz = 16
Global Const $ss_etchedvert = 17
Global Const $ss_etchedframe = 18
Global Const $ss_realsizecontrol = 64
Global Const $ss_noprefix = 128
Global Const $ss_notify = 256
Global Const $ss_centerimage = 512
Global Const $ss_rightjust = 1024
Global Const $ss_sunken = 4096
Global Const $gui_ss_default_label = 0
Global Const $gui_ss_default_graphic = 0
Global Const $gui_ss_default_icon = $ss_notify
Global Const $gui_ss_default_pic = $ss_notify
Global Const $stm_seticon = 368
Global Const $stm_geticon = 369
Global Const $stm_setimage = 370
Global Const $stm_getimage = 371
Global Const $wc_animate = "SysAnimate32"
Global Const $wc_button = "Button"
Global Const $wc_combobox = "ComboBox"
Global Const $wc_comboboxex = "ComboBoxEx32"
Global Const $wc_datetimepick = "SysDateTimePick32"
Global Const $wc_edit = "Edit"
Global Const $wc_header = "SysHeader32"
Global Const $wc_hotkey = "msctls_hotkey32"
Global Const $wc_ipaddress = "SysIPAddress32"
Global Const $wc_link = "SysLink"
Global Const $wc_listbox = "ListBox"
Global Const $wc_listview = "SysListView32"
Global Const $wc_monthcal = "SysMonthCal32"
Global Const $wc_nativefontctl = "NativeFontCtl"
Global Const $wc_pagescroller = "SysPager"
Global Const $wc_progress = "msctls_progress32"
Global Const $wc_rebar = "ReBarWindow32"
Global Const $wc_scrollbar = "ScrollBar"
Global Const $wc_static = "Static"
Global Const $wc_statusbar = "msctls_statusbar32"
Global Const $wc_tabcontrol = "SysTabControl32"
Global Const $wc_toolbar = "ToolbarWindow32"
Global Const $wc_tooltips = "tooltips_class32"
Global Const $wc_trackbar = "msctls_trackbar32"
Global Const $wc_treeview = "SysTreeView32"
Global Const $wc_updown = "msctls_updown32"
Global Const $ws_overlapped = 0
Global Const $ws_tiled = $ws_overlapped
Global Const $ws_maximizebox = 65536
Global Const $ws_minimizebox = 131072
Global Const $ws_tabstop = 65536
Global Const $ws_group = 131072
Global Const $ws_sizebox = 262144
Global Const $ws_thickframe = $ws_sizebox
Global Const $ws_sysmenu = 524288
Global Const $ws_hscroll = 1048576
Global Const $ws_vscroll = 2097152
Global Const $ws_dlgframe = 4194304
Global Const $ws_border = 8388608
Global Const $ws_caption = 12582912
Global Const $ws_overlappedwindow = BitOR($ws_caption, $ws_maximizebox, $ws_minimizebox, $ws_overlapped, $ws_sysmenu, $ws_thickframe)
Global Const $ws_tiledwindow = $ws_overlappedwindow
Global Const $ws_maximize = 16777216
Global Const $ws_clipchildren = 33554432
Global Const $ws_clipsiblings = 67108864
Global Const $ws_disabled = 134217728
Global Const $ws_visible = 268435456
Global Const $ws_minimize = 536870912
Global Const $ws_iconic = $ws_minimize
Global Const $ws_child = 1073741824
Global Const $ws_childwindow = $ws_child
Global Const $ws_popup = -2147483648
Global Const $ws_popupwindow = -2138570752
Global Const $ds_3dlook = 4
Global Const $ds_absalign = 1
Global Const $ds_center = 2048
Global Const $ds_centermouse = 4096
Global Const $ds_contexthelp = 8192
Global Const $ds_control = 1024
Global Const $ds_fixedsys = 8
Global Const $ds_localedit = 32
Global Const $ds_modalframe = 128
Global Const $ds_nofailcreate = 16
Global Const $ds_noidlemsg = 256
Global Const $ds_setfont = 64
Global Const $ds_setforeground = 512
Global Const $ds_shellfont = BitOR($ds_fixedsys, $ds_setfont)
Global Const $ds_sysmodal = 2
Global Const $ws_ex_acceptfiles = 16
Global Const $ws_ex_appwindow = 262144
Global Const $ws_ex_composited = 33554432
Global Const $ws_ex_controlparent = 65536
Global Const $ws_ex_clientedge = 512
Global Const $ws_ex_contexthelp = 1024
Global Const $ws_ex_dlgmodalframe = 1
Global Const $ws_ex_layered = 524288
Global Const $ws_ex_layoutrtl = 4194304
Global Const $ws_ex_left = 0
Global Const $ws_ex_leftscrollbar = 16384
Global Const $ws_ex_ltrreading = 0
Global Const $ws_ex_mdichild = 64
Global Const $ws_ex_noactivate = 134217728
Global Const $ws_ex_noinheritlayout = 1048576
Global Const $ws_ex_noparentnotify = 4
Global Const $ws_ex_right = 4096
Global Const $ws_ex_rightscrollbar = 0
Global Const $ws_ex_rtlreading = 8192
Global Const $ws_ex_staticedge = 131072
Global Const $ws_ex_toolwindow = 128
Global Const $ws_ex_topmost = 8
Global Const $ws_ex_transparent = 32
Global Const $ws_ex_windowedge = 256
Global Const $ws_ex_overlappedwindow = BitOR($ws_ex_clientedge, $ws_ex_windowedge)
Global Const $ws_ex_palettewindow = BitOR($ws_ex_toolwindow, $ws_ex_topmost, $ws_ex_windowedge)
Global Const $wm_null = 0
Global Const $wm_create = 1
Global Const $wm_destroy = 2
Global Const $wm_move = 3
Global Const $wm_sizewait = 4
Global Const $wm_size = 5
Global Const $wm_activate = 6
Global Const $wm_setfocus = 7
Global Const $wm_killfocus = 8
Global Const $wm_setvisible = 9
Global Const $wm_enable = 10
Global Const $wm_setredraw = 11
Global Const $wm_settext = 12
Global Const $wm_gettext = 13
Global Const $wm_gettextlength = 14
Global Const $wm_paint = 15
Global Const $wm_close = 16
Global Const $wm_queryendsession = 17
Global Const $wm_quit = 18
Global Const $wm_erasebkgnd = 20
Global Const $wm_queryopen = 19
Global Const $wm_syscolorchange = 21
Global Const $wm_endsession = 22
Global Const $wm_systemerror = 23
Global Const $wm_showwindow = 24
Global Const $wm_ctlcolor = 25
Global Const $wm_settingchange = 26
Global Const $wm_wininichange = 26
Global Const $wm_devmodechange = 27
Global Const $wm_activateapp = 28
Global Const $wm_fontchange = 29
Global Const $wm_timechange = 30
Global Const $wm_cancelmode = 31
Global Const $wm_setcursor = 32
Global Const $wm_mouseactivate = 33
Global Const $wm_childactivate = 34
Global Const $wm_queuesync = 35
Global Const $wm_getminmaxinfo = 36
Global Const $wm_logoff = 37
Global Const $wm_painticon = 38
Global Const $wm_iconerasebkgnd = 39
Global Const $wm_nextdlgctl = 40
Global Const $wm_alttabactive = 41
Global Const $wm_spoolerstatus = 42
Global Const $wm_drawitem = 43
Global Const $wm_measureitem = 44
Global Const $wm_deleteitem = 45
Global Const $wm_vkeytoitem = 46
Global Const $wm_chartoitem = 47
Global Const $wm_setfont = 48
Global Const $wm_getfont = 49
Global Const $wm_sethotkey = 50
Global Const $wm_gethotkey = 51
Global Const $wm_filesyschange = 52
Global Const $wm_isactiveicon = 53
Global Const $wm_queryparkicon = 54
Global Const $wm_querydragicon = 55
Global Const $wm_winhelp = 56
Global Const $wm_compareitem = 57
Global Const $wm_fullscreen = 58
Global Const $wm_clientshutdown = 59
Global Const $wm_ddemlevent = 60
Global Const $wm_getobject = 61
Global Const $wm_calcscroll = 63
Global Const $wm_testing = 64
Global Const $wm_compacting = 65
Global Const $wm_otherwindowcreated = 66
Global Const $wm_otherwindowdestroyed = 67
Global Const $wm_commnotify = 68
Global Const $wm_mediastatuschange = 69
Global Const $wm_windowposchanging = 70
Global Const $wm_windowposchanged = 71
Global Const $wm_power = 72
Global Const $wm_copyglobaldata = 73
Global Const $wm_copydata = 74
Global Const $wm_canceljournal = 75
Global Const $wm_logonnotify = 76
Global Const $wm_keyf1 = 77
Global Const $wm_notify = 78
Global Const $wm_access_window = 79
Global Const $wm_inputlangchangerequest = 80
Global Const $wm_inputlangchange = 81
Global Const $wm_tcard = 82
Global Const $wm_help = 83
Global Const $wm_userchanged = 84
Global Const $wm_notifyformat = 85
Global Const $wm_qm_activate = 96
Global Const $wm_hook_do_callback = 97
Global Const $wm_syscopydata = 98
Global Const $wm_finaldestroy = 112
Global Const $wm_measureitem_clientdata = 113
Global Const $wm_contextmenu = 123
Global Const $wm_stylechanging = 124
Global Const $wm_stylechanged = 125
Global Const $wm_displaychange = 126
Global Const $wm_geticon = 127
Global Const $wm_seticon = 128
Global Const $wm_nccreate = 129
Global Const $wm_ncdestroy = 130
Global Const $wm_nccalcsize = 131
Global Const $wm_nchittest = 132
Global Const $wm_ncpaint = 133
Global Const $wm_ncactivate = 134
Global Const $wm_getdlgcode = 135
Global Const $wm_syncpaint = 136
Global Const $wm_synctask = 137
Global Const $wm_kludgeminrect = 139
Global Const $wm_lpkdrawswitchwnd = 140
Global Const $wm_uahdestroywindow = 144
Global Const $wm_uahdrawmenu = 145
Global Const $wm_uahdrawmenuitem = 146
Global Const $wm_uahinitmenu = 147
Global Const $wm_uahmeasuremenuitem = 148
Global Const $wm_uahncpaintmenupopup = 149
Global Const $wm_ncmousemove = 160
Global Const $wm_nclbuttondown = 161
Global Const $wm_nclbuttonup = 162
Global Const $wm_nclbuttondblclk = 163
Global Const $wm_ncrbuttondown = 164
Global Const $wm_ncrbuttonup = 165
Global Const $wm_ncrbuttondblclk = 166
Global Const $wm_ncmbuttondown = 167
Global Const $wm_ncmbuttonup = 168
Global Const $wm_ncmbuttondblclk = 169
Global Const $wm_ncxbuttondown = 171
Global Const $wm_ncxbuttonup = 172
Global Const $wm_ncxbuttondblclk = 173
Global Const $wm_ncuahdrawcaption = 174
Global Const $wm_ncuahdrawframe = 175
Global Const $wm_input_device_change = 254
Global Const $wm_input = 255
Global Const $wm_keydown = 256
Global Const $wm_keyfirst = 256
Global Const $wm_keyup = 257
Global Const $wm_char = 258
Global Const $wm_deadchar = 259
Global Const $wm_syskeydown = 260
Global Const $wm_syskeyup = 261
Global Const $wm_syschar = 262
Global Const $wm_sysdeadchar = 263
Global Const $wm_yomichar = 264
Global Const $wm_keylast = 265
Global Const $wm_unichar = 265
Global Const $wm_convertrequest = 266
Global Const $wm_convertresult = 267
Global Const $wm_im_info = 268
Global Const $wm_ime_startcomposition = 269
Global Const $wm_ime_endcomposition = 270
Global Const $wm_ime_composition = 271
Global Const $wm_ime_keylast = 271
Global Const $wm_initdialog = 272
Global Const $wm_command = 273
Global Const $wm_syscommand = 274
Global Const $wm_timer = 275
Global Const $wm_hscroll = 276
Global Const $wm_vscroll = 277
Global Const $wm_initmenu = 278
Global Const $wm_initmenupopup = 279
Global Const $wm_systimer = 280
Global Const $wm_gesture = 281
Global Const $wm_gesturenotify = 282
Global Const $wm_gestureinput = 283
Global Const $wm_gesturenotified = 284
Global Const $wm_menuselect = 287
Global Const $wm_menuchar = 288
Global Const $wm_enteridle = 289
Global Const $wm_menurbuttonup = 290
Global Const $wm_menudrag = 291
Global Const $wm_menugetobject = 292
Global Const $wm_uninitmenupopup = 293
Global Const $wm_menucommand = 294
Global Const $wm_changeuistate = 295
Global Const $wm_updateuistate = 296
Global Const $wm_queryuistate = 297
Global Const $wm_lbtrackpoint = 305
Global Const $wm_ctlcolormsgbox = 306
Global Const $wm_ctlcoloredit = 307
Global Const $wm_ctlcolorlistbox = 308
Global Const $wm_ctlcolorbtn = 309
Global Const $wm_ctlcolordlg = 310
Global Const $wm_ctlcolorscrollbar = 311
Global Const $wm_ctlcolorstatic = 312
Global Const $mn_gethmenu = 481
Global Const $wm_parentnotify = 528
Global Const $wm_entermenuloop = 529
Global Const $wm_exitmenuloop = 530
Global Const $wm_nextmenu = 531
Global Const $wm_sizing = 532
Global Const $wm_capturechanged = 533
Global Const $wm_moving = 534
Global Const $wm_powerbroadcast = 536
Global Const $wm_devicechange = 537
Global Const $wm_mdicreate = 544
Global Const $wm_mdidestroy = 545
Global Const $wm_mdiactivate = 546
Global Const $wm_mdirestore = 547
Global Const $wm_mdinext = 548
Global Const $wm_mdimaximize = 549
Global Const $wm_mditile = 550
Global Const $wm_mdicascade = 551
Global Const $wm_mdiiconarrange = 552
Global Const $wm_mdigetactive = 553
Global Const $wm_dropobject = 554
Global Const $wm_querydropobject = 555
Global Const $wm_begindrag = 556
Global Const $wm_dragloop = 557
Global Const $wm_dragselect = 558
Global Const $wm_dragmove = 559
Global Const $wm_mdisetmenu = 560
Global Const $wm_entersizemove = 561
Global Const $wm_exitsizemove = 562
Global Const $wm_dropfiles = 563
Global Const $wm_mdirefreshmenu = 564
Global Const $wm_touch = 576
Global Const $wm_ime_setcontext = 641
Global Const $wm_ime_notify = 642
Global Const $wm_ime_control = 643
Global Const $wm_ime_compositionfull = 644
Global Const $wm_ime_select = 645
Global Const $wm_ime_char = 646
Global Const $wm_ime_system = 647
Global Const $wm_ime_request = 648
Global Const $wm_ime_keydown = 656
Global Const $wm_ime_keyup = 657
Global Const $wm_ncmousehover = 672
Global Const $wm_mousehover = 673
Global Const $wm_ncmouseleave = 674
Global Const $wm_mouseleave = 675
Global Const $wm_wtssession_change = 689
Global Const $wm_tablet_first = 704
Global Const $wm_tablet_last = 735
Global Const $wm_cut = 768
Global Const $wm_copy = 769
Global Const $wm_paste = 770
Global Const $wm_clear = 771
Global Const $wm_undo = 772
Global Const $wm_paletteischanging = 784
Global Const $wm_hotkey = 786
Global Const $wm_palettechanged = 785
Global Const $wm_sysmenu = 787
Global Const $wm_hookmsg = 788
Global Const $wm_exitprocess = 789
Global Const $wm_wakethread = 790
Global Const $wm_print = 791
Global Const $wm_printclient = 792
Global Const $wm_appcommand = 793
Global Const $wm_querynewpalette = 783
Global Const $wm_themechanged = 794
Global Const $wm_uahinit = 795
Global Const $wm_desktopnotify = 796
Global Const $wm_clipboardupdate = 797
Global Const $wm_dwmcompositionchanged = 798
Global Const $wm_dwmncrenderingchanged = 799
Global Const $wm_dwmcolorizationcolorchanged = 800
Global Const $wm_dwmwindowmaximizedchange = 801
Global Const $wm_dwmexileframe = 802
Global Const $wm_dwmsendiconicthumbnail = 803
Global Const $wm_magnification_started = 804
Global Const $wm_magnification_ended = 805
Global Const $wm_dwmsendiconiclivepreviewbitmap = 806
Global Const $wm_dwmthumbnailsizechanged = 807
Global Const $wm_magnification_output = 808
Global Const $wm_measurecontrol = 816
Global Const $wm_getactiontext = 817
Global Const $wm_forwardkeydown = 819
Global Const $wm_forwardkeyup = 820
Global Const $wm_gettitlebarinfoex = 831
Global Const $wm_notifywow = 832
Global Const $wm_handheldfirst = 856
Global Const $wm_handheldlast = 863
Global Const $wm_afxfirst = 864
Global Const $wm_afxlast = 895
Global Const $wm_penwinfirst = 896
Global Const $wm_penwinlast = 911
Global Const $wm_dde_initiate = 992
Global Const $wm_dde_terminate = 993
Global Const $wm_dde_advise = 994
Global Const $wm_dde_unadvise = 995
Global Const $wm_dde_ack = 996
Global Const $wm_dde_data = 997
Global Const $wm_dde_request = 998
Global Const $wm_dde_poke = 999
Global Const $wm_dde_execute = 1000
Global Const $wm_dbnotification = 1021
Global Const $wm_netconnect = 1022
Global Const $wm_hibernate = 1023
Global Const $wm_user = 1024
Global Const $wm_app = 32768
Global Const $nm_first = 0
Global Const $nm_outofmemory = $nm_first - 1
Global Const $nm_click = $nm_first - 2
Global Const $nm_dblclk = $nm_first - 3
Global Const $nm_return = $nm_first - 4
Global Const $nm_rclick = $nm_first - 5
Global Const $nm_rdblclk = $nm_first - 6
Global Const $nm_setfocus = $nm_first - 7
Global Const $nm_killfocus = $nm_first - 8
Global Const $nm_customdraw = $nm_first - 12
Global Const $nm_hover = $nm_first - 13
Global Const $nm_nchittest = $nm_first - 14
Global Const $nm_keydown = $nm_first - 15
Global Const $nm_releasedcapture = $nm_first - 16
Global Const $nm_setcursor = $nm_first - 17
Global Const $nm_char = $nm_first - 18
Global Const $nm_tooltipscreated = $nm_first - 19
Global Const $nm_ldown = $nm_first - 20
Global Const $nm_rdown = $nm_first - 21
Global Const $nm_themechanged = $nm_first - 22
Global Const $wm_mousefirst = 512
Global Const $wm_mousemove = 512
Global Const $wm_lbuttondown = 513
Global Const $wm_lbuttonup = 514
Global Const $wm_lbuttondblclk = 515
Global Const $wm_rbuttondown = 516
Global Const $wm_rbuttonup = 517
Global Const $wm_rbuttondblclk = 518
Global Const $wm_mbuttondown = 519
Global Const $wm_mbuttonup = 520
Global Const $wm_mbuttondblclk = 521
Global Const $wm_mousewheel = 522
Global Const $wm_xbuttondown = 523
Global Const $wm_xbuttonup = 524
Global Const $wm_xbuttondblclk = 525
Global Const $wm_mousehwheel = 526
Global Const $ps_solid = 0
Global Const $ps_dash = 1
Global Const $ps_dot = 2
Global Const $ps_dashdot = 3
Global Const $ps_dashdotdot = 4
Global Const $ps_null = 5
Global Const $ps_insideframe = 6
Global Const $ps_userstyle = 7
Global Const $ps_alternate = 8
Global Const $ps_endcap_round = 0
Global Const $ps_endcap_square = 256
Global Const $ps_endcap_flat = 512
Global Const $ps_join_bevel = 4096
Global Const $ps_join_miter = 8192
Global Const $ps_join_round = 0
Global Const $ps_geometric = 65536
Global Const $ps_cosmetic = 0
Global Const $lwa_alpha = 2
Global Const $lwa_colorkey = 1
Global Const $rgn_and = 1
Global Const $rgn_or = 2
Global Const $rgn_xor = 3
Global Const $rgn_diff = 4
Global Const $rgn_copy = 5
Global Const $errorregion = 0
Global Const $nullregion = 1
Global Const $simpleregion = 2
Global Const $complexregion = 3
Global Const $transparent = 1
Global Const $opaque = 2
Global Const $ccm_first = 8192
Global Const $ccm_getunicodeformat = ($ccm_first + 6)
Global Const $ccm_setunicodeformat = ($ccm_first + 5)
Global Const $ccm_setbkcolor = $ccm_first + 1
Global Const $ccm_setcolorscheme = $ccm_first + 2
Global Const $ccm_getcolorscheme = $ccm_first + 3
Global Const $ccm_getdroptarget = $ccm_first + 4
Global Const $ccm_setwindowtheme = $ccm_first + 11
Global Const $ga_parent = 1
Global Const $ga_root = 2
Global Const $ga_rootowner = 3
Global Const $sm_cxscreen = 0
Global Const $sm_cyscreen = 1
Global Const $sm_cxvscroll = 2
Global Const $sm_cyhscroll = 3
Global Const $sm_cycaption = 4
Global Const $sm_cxborder = 5
Global Const $sm_cyborder = 6
Global Const $sm_cxdlgframe = 7
Global Const $sm_cydlgframe = 8
Global Const $sm_cyvthumb = 9
Global Const $sm_cxhthumb = 10
Global Const $sm_cxicon = 11
Global Const $sm_cyicon = 12
Global Const $sm_cxcursor = 13
Global Const $sm_cycursor = 14
Global Const $sm_cymenu = 15
Global Const $sm_cxfullscreen = 16
Global Const $sm_cyfullscreen = 17
Global Const $sm_cykanjiwindow = 18
Global Const $sm_mousepresent = 19
Global Const $sm_cyvscroll = 20
Global Const $sm_cxhscroll = 21
Global Const $sm_debug = 22
Global Const $sm_swapbutton = 23
Global Const $sm_reserved1 = 24
Global Const $sm_reserved2 = 25
Global Const $sm_reserved3 = 26
Global Const $sm_reserved4 = 27
Global Const $sm_cxmin = 28
Global Const $sm_cymin = 29
Global Const $sm_cxsize = 30
Global Const $sm_cysize = 31
Global Const $sm_cxframe = 32
Global Const $sm_cyframe = 33
Global Const $sm_cxmintrack = 34
Global Const $sm_cymintrack = 35
Global Const $sm_cxdoubleclk = 36
Global Const $sm_cydoubleclk = 37
Global Const $sm_cxiconspacing = 38
Global Const $sm_cyiconspacing = 39
Global Const $sm_menudropalignment = 40
Global Const $sm_penwindows = 41
Global Const $sm_dbcsenabled = 42
Global Const $sm_cmousebuttons = 43
Global Const $sm_secure = 44
Global Const $sm_cxedge = 45
Global Const $sm_cyedge = 46
Global Const $sm_cxminspacing = 47
Global Const $sm_cyminspacing = 48
Global Const $sm_cxsmicon = 49
Global Const $sm_cysmicon = 50
Global Const $sm_cysmcaption = 51
Global Const $sm_cxsmsize = 52
Global Const $sm_cysmsize = 53
Global Const $sm_cxmenusize = 54
Global Const $sm_cymenusize = 55
Global Const $sm_arrange = 56
Global Const $sm_cxminimized = 57
Global Const $sm_cyminimized = 58
Global Const $sm_cxmaxtrack = 59
Global Const $sm_cymaxtrack = 60
Global Const $sm_cxmaximized = 61
Global Const $sm_cymaximized = 62
Global Const $sm_network = 63
Global Const $sm_cleanboot = 67
Global Const $sm_cxdrag = 68
Global Const $sm_cydrag = 69
Global Const $sm_showsounds = 70
Global Const $sm_cxmenucheck = 71
Global Const $sm_cymenucheck = 72
Global Const $sm_slowmachine = 73
Global Const $sm_mideastenabled = 74
Global Const $sm_mousewheelpresent = 75
Global Const $sm_xvirtualscreen = 76
Global Const $sm_yvirtualscreen = 77
Global Const $sm_cxvirtualscreen = 78
Global Const $sm_cyvirtualscreen = 79
Global Const $sm_cmonitors = 80
Global Const $sm_samedisplayformat = 81
Global Const $sm_immenabled = 82
Global Const $sm_cxfocusborder = 83
Global Const $sm_cyfocusborder = 84
Global Const $sm_tabletpc = 86
Global Const $sm_mediacenter = 87
Global Const $sm_starter = 88
Global Const $sm_serverr2 = 89
Global Const $sm_cmetrics = 90
Global Const $sm_remotesession = 4096
Global Const $sm_shuttingdown = 8192
Global Const $sm_remotecontrol = 8193
Global Const $sm_caretblinkingenabled = 8194
Global Const $blackness = 66
Global Const $captureblt = 1073741824
Global Const $dstinvert = 5570569
Global Const $mergecopy = 12583114
Global Const $mergepaint = 12255782
Global Const $nomirrorbitmap = -2147483648
Global Const $notsrccopy = 3342344
Global Const $notsrcerase = 1114278
Global Const $patcopy = 15728673
Global Const $patinvert = 5898313
Global Const $patpaint = 16452105
Global Const $srcand = 8913094
Global Const $srccopy = 13369376
Global Const $srcerase = 4457256
Global Const $srcinvert = 6684742
Global Const $srcpaint = 15597702
Global Const $whiteness = 16711778
Global Const $dt_bottom = 8
Global Const $dt_calcrect = 1024
Global Const $dt_center = 1
Global Const $dt_editcontrol = 8192
Global Const $dt_end_ellipsis = 32768
Global Const $dt_expandtabs = 64
Global Const $dt_externalleading = 512
Global Const $dt_hideprefix = 1048576
Global Const $dt_internal = 4096
Global Const $dt_left = 0
Global Const $dt_modifystring = 65536
Global Const $dt_noclip = 256
Global Const $dt_nofullwidthcharbreak = 524288
Global Const $dt_noprefix = 2048
Global Const $dt_path_ellipsis = 16384
Global Const $dt_prefixonly = 2097152
Global Const $dt_right = 2
Global Const $dt_rtlreading = 131072
Global Const $dt_singleline = 32
Global Const $dt_tabstop = 128
Global Const $dt_top = 0
Global Const $dt_vcenter = 4
Global Const $dt_wordbreak = 16
Global Const $dt_word_ellipsis = 262144
Global Const $rdw_erase = 4
Global Const $rdw_frame = 1024
Global Const $rdw_internalpaint = 2
Global Const $rdw_invalidate = 1
Global Const $rdw_noerase = 32
Global Const $rdw_noframe = 2048
Global Const $rdw_nointernalpaint = 16
Global Const $rdw_validate = 8
Global Const $rdw_erasenow = 512
Global Const $rdw_updatenow = 256
Global Const $rdw_allchildren = 128
Global Const $rdw_nochildren = 64
Global Const $wm_renderformat = 773
Global Const $wm_renderallformats = 774
Global Const $wm_destroyclipboard = 775
Global Const $wm_drawclipboard = 776
Global Const $wm_paintclipboard = 777
Global Const $wm_vscrollclipboard = 778
Global Const $wm_sizeclipboard = 779
Global Const $wm_askcbformatname = 780
Global Const $wm_changecbchain = 781
Global Const $wm_hscrollclipboard = 782
Global Const $hterror = -2
Global Const $httransparent = -1
Global Const $htnowhere = 0
Global Const $htclient = 1
Global Const $htcaption = 2
Global Const $htsysmenu = 3
Global Const $htgrowbox = 4
Global Const $htsize = $htgrowbox
Global Const $htmenu = 5
Global Const $hthscroll = 6
Global Const $htvscroll = 7
Global Const $htminbutton = 8
Global Const $htmaxbutton = 9
Global Const $htleft = 10
Global Const $htright = 11
Global Const $httop = 12
Global Const $httopleft = 13
Global Const $httopright = 14
Global Const $htbottom = 15
Global Const $htbottomleft = 16
Global Const $htbottomright = 17
Global Const $htborder = 18
Global Const $htreduce = $htminbutton
Global Const $htzoom = $htmaxbutton
Global Const $htsizefirst = $htleft
Global Const $htsizelast = $htbottomright
Global Const $htobject = 19
Global Const $htclose = 20
Global Const $hthelp = 21
Global Const $color_scrollbar = 0
Global Const $color_background = 1
Global Const $color_activecaption = 2
Global Const $color_inactivecaption = 3
Global Const $color_menu = 4
Global Const $color_window = 5
Global Const $color_windowframe = 6
Global Const $color_menutext = 7
Global Const $color_windowtext = 8
Global Const $color_captiontext = 9
Global Const $color_activeborder = 10
Global Const $color_inactiveborder = 11
Global Const $color_appworkspace = 12
Global Const $color_highlight = 13
Global Const $color_highlighttext = 14
Global Const $color_btnface = 15
Global Const $color_btnshadow = 16
Global Const $color_graytext = 17
Global Const $color_btntext = 18
Global Const $color_inactivecaptiontext = 19
Global Const $color_btnhighlight = 20
Global Const $color_3ddkshadow = 21
Global Const $color_3dlight = 22
Global Const $color_infotext = 23
Global Const $color_infobk = 24
Global Const $color_hotlight = 26
Global Const $color_gradientactivecaption = 27
Global Const $color_gradientinactivecaption = 28
Global Const $color_menuhilight = 29
Global Const $color_menubar = 30
Global Const $color_desktop = 1
Global Const $color_3dface = 15
Global Const $color_3dshadow = 16
Global Const $color_3dhighlight = 20
Global Const $color_3dhilight = 20
Global Const $color_btnhilight = 20
Global Const $hinst_commctrl = -1
Global Const $idb_std_small_color = 0
Global Const $idb_std_large_color = 1
Global Const $idb_view_small_color = 4
Global Const $idb_view_large_color = 5
Global Const $idb_hist_small_color = 8
Global Const $idb_hist_large_color = 9
Global Const $startf_forceofffeedback = 128
Global Const $startf_forceonfeedback = 64
Global Const $startf_preventpinning = 8192
Global Const $startf_runfullscreen = 32
Global Const $startf_titleisappid = 4096
Global Const $startf_titleislinkname = 2048
Global Const $startf_usecountchars = 8
Global Const $startf_usefillattribute = 16
Global Const $startf_usehotkey = 512
Global Const $startf_useposition = 4
Global Const $startf_useshowwindow = 1
Global Const $startf_usesize = 2
Global Const $startf_usestdhandles = 256
Global Const $cdds_prepaint = 1
Global Const $cdds_postpaint = 2
Global Const $cdds_preerase = 3
Global Const $cdds_posterase = 4
Global Const $cdds_item = 65536
Global Const $cdds_itemprepaint = 65537
Global Const $cdds_itempostpaint = 65538
Global Const $cdds_itempreerase = 65539
Global Const $cdds_itemposterase = 65540
Global Const $cdds_subitem = 131072
Global Const $cdis_selected = 1
Global Const $cdis_grayed = 2
Global Const $cdis_disabled = 4
Global Const $cdis_checked = 8
Global Const $cdis_focus = 16
Global Const $cdis_default = 32
Global Const $cdis_hot = 64
Global Const $cdis_marked = 128
Global Const $cdis_indeterminate = 256
Global Const $cdis_showkeyboardcues = 512
Global Const $cdis_nearhot = 1024
Global Const $cdis_othersidehot = 2048
Global Const $cdis_drophilited = 4096
Global Const $cdrf_dodefault = 0
Global Const $cdrf_newfont = 2
Global Const $cdrf_skipdefault = 4
Global Const $cdrf_notifypostpaint = 16
Global Const $cdrf_notifyitemdraw = 32
Global Const $cdrf_notifysubitemdraw = 32
Global Const $cdrf_notifyposterase = 64
Global Const $cdrf_doerase = 8
Global Const $cdrf_skippostpaint = 256
Global Const $gui_ss_default_gui = BitOR($ws_minimizebox, $ws_caption, $ws_popup, $ws_sysmenu)


Func getitembyagentid2($iagentid)
	Return getitembyitemid(memoryread(getagentptr($iagentid) + 200))
EndFunc

#Region BotGlobals
	Global $rarity_gold = 2624, $rarity_green = 2627
	Global $firstrun = True
	Global $newsetup = False
#EndRegion
#Region GUIGlobals
	Global $guititle = "Plant Fibres & Kurzick Points 1.2"
	Global $newguititle
	Global $boolrun = False
	Global $weakcounter = 0
	Global $sec = 0
	Global $min = 0
	Global $hour = 0
	Global $runs = 0
	Global $goodruns = 0
	Global $badruns = 0
	Global $keep_shields = False
	Global $rendering = True
#EndRegion
#Region GUI
	Opt("GUIOnEventMode", 1)
	$cgui = GUICreate($guititle & "Plant Fibres & Kurzick Points 1.2", 389, 200, 341, 397)
	$gmain = GUICtrlCreateGroup("Main", 0, 0, 201, 81)
	$ccharname = GUICtrlCreateCombo("", 8, 16, 185, 25, BitOR($cbs_dropdown, $cbs_autohscroll))
	GUICtrlSetData(-1, getloggedcharnames())
	GUICtrlSetBkColor(-1, 16579836)
	$bstart = GUICtrlCreateButton("Start", 8, 40, 186, 33)
	$bpause = GUICtrlCreateButton("Pause", 0, 0, 1, 1)
	GUICtrlSetState($bpause, $gui_disable)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$gopt = GUICtrlCreateGroup("Actions", 208, 80, 89, 113)
	$select_shields = GUICtrlCreateCheckbox("Shields", 216, 96, 75, 17)
	$Amber = GUICtrlCreateRadio("Amber", 216, 120, 75, 17) ;new code
	$Donate = GUICtrlCreateRadio("Donate", 216, 144, 75, 17) ;new code
	$Scrolls = GUICtrlCreateRadio("Scrolls", 216, 168, 75, 17) ;new code
	$cbxhidegw = GUICtrlCreateCheckbox("Rendering", 312, 168, 75, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$gaction = GUICtrlCreateGroup("Status", 0, 80, 201, 113)
	$laction = GUICtrlCreateLabel("Waiting...", 8, 104, 189, 72, BitOR($ss_center, $ss_centerimage))
	GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$ltime = GUICtrlCreateLabel("00:00:00", 208, 8, 175, 57, BitOR($ss_center, $ss_centerimage), $ws_ex_staticedge)
	GUICtrlSetFont(-1, 24, 800, 0, "MS Sans Serif")
	$gstats = GUICtrlCreateGroup("Stats", 304, 80, 81, 113)
	$cruns = GUICtrlCreateLabel("Runs:", 312, 96, 32, 17)
	$lruns = GUICtrlCreateLabel("0", 352, 96, 18, 17)
	$cwins = GUICtrlCreateLabel("Wins:", 312, 120, 31, 17)
	$lwins = GUICtrlCreateLabel("0", 352, 120, 26, 17)
	$cfails = GUICtrlCreateLabel("Fails", 312, 144, 25, 17)
	$lfails = GUICtrlCreateLabel("0", 352, 144, 10, 17)
	
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlSetOnEvent($bstart, "GUIHandler")
	GUICtrlSetOnEvent($bpause, "GUIHandler")
	GUICtrlSetOnEvent($cbxhidegw, "GUIHandler")
	GUISetOnEvent($gui_event_close, "GUIHandler")
	GUICtrlSetState($Donate, $GUI_CHECKED)
	GUISetState(@SW_SHOW)
	While 1
		If $boolrun = False Then
			upd("Paused")
			While $boolrun = False
				Sleep(100)
			WEnd
		EndIf
		main()
	WEnd
	While $boolrun = False
		Sleep(100)
	WEnd
#EndRegion GUI
#Region Main

	Func main()
		If $firstrun Then
			upd("Going to outpost")
			If getmapid() <> 349 Then travelto(349)
			upd("Loading Skills")
;			clearattributes()
			loadskilltemplate("OgcTcZ/8ZiHRn5A6usBimE3R4AA")
			gooutside()
			upd("Preparing fast way out")
			moveto(-11097, 19483)
			moveto(-11220, 19839)
			move(-11343, 20195)
			Sleep(GetPing())
			waitmaploading(349)
			$firstrun = False
		EndIf
		If $newsetup Then
			upd("Going to outpost")
			If getmapid() <> 349 Then travelto(349)
			upd("Preparing fast way out")
			gooutside()
			moveto(-11097, 19483)
			moveto(-11220, 19839)
			move(-11343, 20195)
			Sleep(GetPing())
			waitmaploading(349)
			$newsetup = False
		EndIf
		If countslots() < 10 Then
			upd("Inventory")
			inventory(4)
		EndIf
		
		If FactionCheck() = True Then TurnInFaction()
		
		If GetGoldCharacter() < 150 Then
			WithdrawGold(150)
		EndIf	
	
		gooutside()
		upd("Moving to farm spot")
		If getmapid() = 195 Then
			useskillex(4, -2)
			useskillex(5, -2)
			
			;new code - start
		
		
			If GetLuxonFaction() > GetKurzickFaction() Then
				upd("Taking blessing")
				$priest = GetNearestNPCToCoords(-8412, 18454)
				gotonpc($priest)
				upd("Get Blessing")
				Dialog(0x81)
				sleep(GetPing())
				Dialog(0x84)
				sleep(GetPing())
				Dialog(0x86)
				sleep(GetPing())
			
			Else
				upd("Get Blessing")
				Dialog(0x81)
				sleep(100)
				Dialog(0x2)
				sleep(100)
				Dialog(0x84)
				sleep(100)
				Dialog(0x86)
			EndIf
			
			;moveto(-8477, 18580) old coordinate, that might have caused stuck problems
			; moveto(-7878, 18196) old coordinate, causes stuck problems sometimes
			moveto(-7780, 18704)
			moveto(-6908, 17541)
			Do
				move(-4900, 15647)
				Sleep(100)
			Until getnumberoffoesinrangeofagent(-2, 1300) > 0
			upd("Casting Enchants")
			useskillex(1, -2)
			useskillex(2, -2)
			useskillex(3, -2)
			upd("Aggroing")
			Do
				move(-4900, 15647)
				Sleep(100)
			Until getnumberoffoesinrangeofagent(-2, 1050) > 8
		EndIf
		upd("Balling")
		If getisliving(-2) Then
			Do
				useskill(6, -2)
				Sleep(100)
			Until getskillbarskillrecharge(6) <> 0
		EndIf
		If getisliving(-2) Then moveto(-6091, 17961)
		If getisliving(-2) Then tolsleep(1000)
		If getisliving(-2) Then moveto(-6528, 18439)
		If getisliving(-2) Then tolsleep(1000)
		If (getisliving(-2)) AND (getskillbarskillrecharge(2) = 0) Then
			useskillex(2, -2)
		EndIf
		upd("Killing")
		If getisliving(-2) Then useskillex(7, getnearestagenttocoords(-6036, 17064))
		Do
			Sleep(100)
		Until getdistance(-2, getnearestagenttocoords(-6036, 17064)) < 160 OR getisdead(-2)
		If getisliving(-2) Then useskillex(8, -2)
		If getisdead(-2) Then omgtheykilledkennyyoubastards()
		Do
			Sleep(100)
		Until (getskillbarskillrecharge(2) = 0) OR (getnumberoffoesinrangeofagent(-2, 160) < 3) OR getisdead(-2)
		If getisliving(-2) Then useskillex(2, -2)
		Do
			Sleep(250)
		Until getnumberoffoesinrangeofagent(-2, 160) < 3 OR getisdead(-2)
		If getisdead(-2) Then omgtheykilledkennyyoubastards()
		upd("Looting")
		If getisliving(-2) Then
			Sleep(2000)
			pickuploot()
			guiupdate()
			upd("Going back to town")
			returnoutpost()

			; _PurgeHook()
	
			clearmemory()
			main()
		EndIf
	EndFunc

#EndRegion Main
#Region GUIFuncs

	Func guihandler()
		Switch (@GUI_CtrlId)
			Case $bstart
				If GUICtrlRead($ccharname) = "" Then
					If initialize(ProcessExists("gw.exe"), True) = False Then
						MsgBox(0, "Error!", "Guild Wars is not running!")
						Exit
					EndIf
				Else
					initialize(GUICtrlRead($ccharname), True)
				EndIf
				WinSetTitle($guititle, "", getcharname() & " - " & $guititle)
				$boolrun = True
				ensureenglish(True)
				GUICtrlSetState($bpause, $gui_enable)
				GUICtrlSetState($bstart, $gui_disable)
				AdlibRegister("TimeUpdater", 1000)
			Case $bpause
				$boolrun = False
				GUICtrlSetState($bpause, $gui_disable)
				GUICtrlSetState($bstart, $gui_enable)
				AdlibUnRegister("TimeUpdater")
				reset()
			Case $cbxhidegw
				togglerendering()
			Case $gui_event_close
				Exit
		EndSwitch
	EndFunc

	Func togglerendering()
		If $rendering Then
			disablerendering()
			WinSetState(getwindowhandle(), "", @SW_HIDE)
			clearmemory()
		Else
			enablerendering()
			WinSetState(getwindowhandle(), "", @SW_SHOW)
		EndIf
		$rendering = NOT $rendering
	EndFunc

	Func reset()
		$weakcounter = 0
		$sec = 0
		$min = 0
		$hour = 0
		$runs = 0
		$goodruns = 0
		$badruns = 0
		GUICtrlSetData($ltime, "00:00:00")
		GUICtrlSetData($lruns, "0")
		GUICtrlSetData($lwins, "0")
		GUICtrlSetData($lfails, "0")
	EndFunc

	Func guiupdate()
		$runs += 1
		$goodruns += 1
		GUICtrlSetData($lruns, $runs)
		GUICtrlSetData($lwins, $goodruns)
	EndFunc

	Func timeupdater()
		$weakcounter += 1
		$sec += 1
		If $sec = 60 Then
			$min += 1
			$sec = $sec - 60
		EndIf
		If $min = 60 Then
			$hour += 1
			$min = $min - 60
		EndIf
		If $sec < 10 Then
			$l_sec = "0" & $sec
		Else
			$l_sec = $sec
		EndIf
		If $min < 10 Then
			$l_min = "0" & $min
		Else
			$l_min = $min
		EndIf
		If $hour < 10 Then
			$l_hour = "0" & $hour
		Else
			$l_hour = $hour
		EndIf
		GUICtrlSetData($ltime, $l_hour & ":" & $l_min & ":" & $l_sec)
	EndFunc

	Func upd($msg)
		GUICtrlSetData($laction, $msg)
	EndFunc

#EndRegion GUIFuncs#
#Region Botfuncs

	Func returnoutpost()
		resign()
		pingsleep(5000)
		returntooutpost()
		waitmaploading(349)
	EndFunc

	Func gooutside()
		upd("Going Outside")
		switchmode(1)
		move(-11172, -23105)
		Sleep(100)
		waitmaploading(195)
	EndFunc

	Func pingsleep($time)
		Sleep($time + getping())
	EndFunc

	Func pickuploot()
		Local $lme
		Local $lblockedtimer
		Local $lblockedcount = 0
		Local $litemexists = True
		Local $distance
		For $i = 1 To getmaxagents()
			If getisdead(-2) Then
				omgtheykilledkennyyoubastards()
			EndIf
			$lagent = getagentbyid($i)
			If NOT getismovable($lagent) Then ContinueLoop
			$ldistance = getdistance($lagent)
			If $ldistance > 2000 Then ContinueLoop
			$litem = getitembyagentid($i)
			If canpickup($litem) Then
				upd("Picking Up Loot")
				Do
					If getdistance($lagent) > 150 Then move(DllStructGetData($lagent, "X"), DllStructGetData($lagent, "Y"), 100)
					pickupitem($litem)
					Sleep(getping())
					Do
						Sleep(100)
						$lme = getagentbyid(-2)
					Until DllStructGetData($lme, "MoveX") == 0 AND DllStructGetData($lme, "MoveY") == 0
					$lblockedtimer = TimerInit()
					Do
						Sleep(3)
						$litemexists = IsDllStruct(getagentbyid($i))
					Until NOT $litemexists OR TimerDiff($lblockedtimer) > Random(500, 1000, 1)
					If $litemexists Then $lblockedcount += 1
				Until NOT $litemexists OR $lblockedcount > 5
			EndIf
		Next
	EndFunc

	Func omgtheykilledkennyyoubastards()
		$runs += 1
		$badruns += 1
		GUICtrlSetData($lruns, $runs)
		GUICtrlSetData($lfails, $badruns)
		$newsetup = True
		returnoutpost()
		clearmemory()
		main()
	EndFunc

	Func canpickup($aitem)
		$m = DllStructGetData($aitem, "ModelID")
		$type = DllStructGetData($aitem, "Type")
		$r = getrarity($aitem)
		If $r = $rarity_gold OR $r = $rarity_green Then
			Return True
		EndIf
		If $m = 146 Then
			$e = DllStructGetData($aitem, "ExtraID")
			If $e = 10 OR $e = 12 Then
				Return True
			Else
				Return False
			EndIf
		ElseIf $m = 22751 Then
			Return True
		ElseIf ($m = 2511) AND (getgoldcharacter() < 98980) Then
			Return True
		ElseIf $m > 21785 AND $m < 21806 Then
			Return True
		ElseIf $m = 819 OR $m = 934 OR $m = 956 Then
			Return True
		ElseIf $m = 868 OR $m = 904 OR $m = 906 OR $m = 934 OR $m = 957 Then
			Return True
		ElseIf $m = 910 OR $m = 5585 OR $m = 6049 OR $m = 6368 OR $m = 6369 OR $m = 6370 OR $m = 6375 OR $m = 6376 OR $m = 21488 OR $m = 21489 OR $m = 21491 OR $m = 21492 OR $m = 21809 OR $m = 21810 OR $m = 21812 OR $m = 21813 OR $m = 22190 OR $m = 22191 OR $m = 22269 OR $m = 22644 OR $m = 22752 OR $m = 24593 OR $m = 24862 OR $m = 26784 OR $m = 28433 OR $m = 28434 OR $m = 28435 OR $m = 28436 OR $m = 29436 OR $m = 30855 OR $m = 31151 OR $m = 31152 OR $m = 31153 OR $m = 35121 OR $m = 35124 OR $m = 37765 OR $m = 18345 Then
			Return True
		Else
			Return False
		EndIf
	EndFunc

#EndRegion Botfuncs
#Region Inventory

	Func inventory($abags = 4)
		upd("Travelling to Guild Hall")
		travelgh()
		upd("Going to Xunlai Chest")
		$xunlai = getnearestnpctocoords(-804, 7667)
		gotonpc($xunlai)
		Sleep(500)
		upd("Going to Merchant")
		$merch = getnearestnpctocoords(-2168, 8069)
		gotonpc($merch)
		#Region CheckGUI
			If GUICtrlRead($select_shields) = 1 Then
				$keep_shields = True
			Else
				$keep_shields = False
			EndIf
		#EndRegion
		For $i = 1 To $abags
			ident($i)
		Next
		For $i = 1 To $abags
			salvage($i)
		Next
		If getplantcount() > 250 Then
			storeplants(1, 20)
			storeplants(2, 5)
			storeplants(3, 10)
			storeplants(4, 10)
		EndIf
		If $keep_shields = True Then
			storeshields(1, 20)
			storeshields(2, 5)
			storeshields(3, 10)
			storeshields(4, 10)
		EndIf
		For $i = 1 To $abags
			sell($i)
		Next
		depositgold(getgoldcharacter())
		leavegh()
	EndFunc

	Func ident($bagindex)
		Local $bag
		Local $i
		Local $aitem
		$bag = getbag($bagindex)
		upd("Identifying")
		For $i = 1 To DllStructGetData($bag, "slots")
			If findidkit() = 0 Then
				If getgoldcharacter() < 500 AND getgoldstorage() > 499 Then
					withdrawgold(500)
					Sleep(getping() + 500)
				EndIf
				Local $j = 0
				Do
					buyitem(6, 1, 500)
					Sleep(getping() + 500)
					$j = $j + 1
				Until findidkit() <> 0 OR $j = 3
				If $j = 3 Then ExitLoop
				Sleep(getping() + 500)
			EndIf
			$aitem = getitembyslot($bagindex, $i)
			If DllStructGetData($aitem, "ID") = 0 Then ContinueLoop
			identifyitem($aitem)
			Sleep(getping() + 500)
		Next
	EndFunc

	Func salvage($lbag)
		Local $abag
		If NOT IsDllStruct($lbag) Then $abag = getbag($lbag)
		Local $litem
		Local $lsalvagetype
		Local $lsalvagecount
		upd("Salvaging")
		For $i = 1 To DllStructGetData($abag, "Slots")
			$litem = getitembyslot($abag, $i)
			salvagekit()
			$q = DllStructGetData($litem, "Quantity")
			$t = DllStructGetData($litem, "Type")
			$m = DllStructGetData($litem, "ModelID")
			If (DllStructGetData($litem, "ID") == 0) Then ContinueLoop
			If $m = 819 OR $m = 868 OR $m = 904 OR $m = 906 OR ($t = 5 AND $m = 934) OR $m = 957 Then
				If $q >= 1 Then
					For $j = 1 To $q
						salvagekit()
						startsalvage($litem)
						Sleep(getping() + Random(1000, 1500, 1))
						salvagematerials()
						While (getping() > 1250)
							rndsleep(250)
						WEnd
						Local $ldeadlock = TimerInit()
						Local $bitem
						Do
							Sleep(300)
							$bitem = getitembyslot($abag, $i)
							If (TimerDiff($ldeadlock) > 20000) Then ExitLoop
						Until (DllStructGetData($bitem, "Quantity") = $q - $j)
					Next
				EndIf
			EndIf
		Next
		Return True
	EndFunc

	Func salvagekit()
		If findsalvagekit() = 0 Then
			If getgoldcharacter() < 100 Then
				withdrawgold(100)
				rndsleep(2000)
			EndIf
			buyitem(2, 1, 100)
			rndsleep(1000)
		EndIf
	EndFunc

	Func getplantcount()
		Local $aamountplant
		Local $abag
		Local $aitem
		Local $i
		For $i = 1 To 4
			$abag = getbag($i)
			For $j = 1 To DllStructGetData($abag, "Slots")
				$aitem = getitembyslot($abag, $j)
				If DllStructGetData($aitem, "ModelID") == 934 Then
					$aamountplant += DllStructGetData($aitem, "Quantity")
				Else
					ContinueLoop
				EndIf
			Next
		Next
		Return $aamountplant
	EndFunc

	Func storeplants($bagindex, $numofslots)
		Local $r_gold = 2624
		Local $aitem
		Local $m
		Local $q
		Local $bag
		Local $slot
		Local $full
		Local $nslot
		upd("Storing Plant Fibers")
		For $i = 1 To $numofslots
			$aitem = getitembyslot($bagindex, $i)
			If DllStructGetData($aitem, "ID") = 0 Then ContinueLoop
			$m = DllStructGetData($aitem, "ModelID")
			$q = DllStructGetData($aitem, "quantity")
			$t = DllStructGetData($aitem, "Type")
			$r = getrarity($aitem)
			$a = DllStructGetData($aitem, "Quantity")
			If $m = 934 AND $a = 250 Then
				Do
					For $bag = 8 To 16
						$slot = findemptyslot($bag)
						$slot = @extended
						If $slot <> 0 Then
							$full = False
							$nslot = $slot
							ExitLoop 2
						Else
							$full = True
						EndIf
						Sleep(400)
					Next
				Until $full = True
				If $full = False Then
					moveitem($aitem, $bag, $nslot)
					Sleep(getping() + 500)
				EndIf
			EndIf
		Next
	EndFunc

	Func storeshields($bagindex, $numofslots)
		Local $r_gold = 2624
		Local $aitem
		Local $m
		Local $q
		Local $bag
		Local $slot
		Local $full
		Local $nslot
		upd("Storing Items")
		For $i = 1 To $numofslots
			$aitem = getitembyslot($bagindex, $i)
			If DllStructGetData($aitem, "ID") = 0 Then ContinueLoop
			$m = DllStructGetData($aitem, "ModelID")
			$q = DllStructGetData($aitem, "quantity")
			$t = DllStructGetData($aitem, "Type")
			$r = getrarity($aitem)
			If $t = 24 AND $r = $r_gold Then
				Do
					For $bag = 8 To 16
						$slot = findemptyslot($bag)
						$slot = @extended
						If $slot <> 0 Then
							$full = False
							$nslot = $slot
							ExitLoop 2
						Else
							$full = True
						EndIf
						Sleep(400)
					Next
				Until $full = True
				If $full = False Then
					moveitem($aitem, $bag, $nslot)
					Sleep(getping() + 500)
				EndIf
			EndIf
		Next
	EndFunc

	Func findemptyslot($bagindex)
		Local $liteminfo, $aslot
		For $aslot = 1 To DllStructGetData(getbag($bagindex), "Slots")
			Sleep(40)
			$liteminfo = getitembyslot($bagindex, $aslot)
			If DllStructGetData($liteminfo, "ID") = 0 Then
				SetExtended($aslot)
				ExitLoop
			EndIf
		Next
		Return 0
	EndFunc

	Func sell($bagindex)
		Local $aitem
		Local $bag = getbag($bagindex)
		Local $numofslots = DllStructGetData($bag, "slots")
		For $i = 1 To $numofslots
			$aitem = getitembyslot($bagindex, $i)
			If DllStructGetData($aitem, "ID") = 0 Then ContinueLoop
			If cansell($aitem) Then
				sellitem($aitem)
			EndIf
			Sleep(getping() + 250)
		Next
	EndFunc

	Func cansell($litem)
		Local $r_gold = 2624
		$t = DllStructGetData($litem, "type")
		$m = DllStructGetData($litem, "ModelID")
		$r = DllStructGetData($litem, "Rarity")
		Switch $t
			Case 24
				If $r = $r_gold Then
					Return False
				Else
					Return True
				EndIf
			Case 30
				Return False
			Case Else
				If $m = 22751 OR $m = 146 OR $m = 934 OR $m = 6532 OR $m = 3256 Then ;6532 = Amber chunks, 3256 = Urgoz Scroll
					Return False
				Else
					Return True
				EndIf
		EndSwitch
	EndFunc

	Func countslots()
		Local $freeslots = 0, $lbag, $abag
		For $abag = 1 To 4
			$lbag = getbag($abag)
			$freeslots += DllStructGetData($lbag, "slots") - DllStructGetData($lbag, "ItemsCount")
		Next
		Return $freeslots
	EndFunc

	Func gonearestnpctocoords($x, $y)
		Local $guy, $me
		Do
			rndsleep(250)
			$guy = getnearestnpctocoords($x, $y)
		Until DllStructGetData($guy, "Id") <> 0
		changetarget($guy)
		rndsleep(250)
		gonpc($guy)
		rndsleep(250)
		Do
			rndsleep(500)
			move(DllStructGetData($guy, "X"), DllStructGetData($guy, "Y"), 40)
			rndsleep(500)
			gonpc($guy)
			rndsleep(250)
			$me = getagentbyid(-2)
		Until computedistance(DllStructGetData($me, "X"), DllStructGetData($me, "Y"), DllStructGetData($guy, "X"), DllStructGetData($guy, "Y")) < 250
		rndsleep(1000)
	EndFunc

	
Func FactionCheck()
	upd("Check Kurzick points")
	RndSleep(250)
	If GetKurzickFaction() > GetMaxKurzickFaction() - 500 Then
		Return True
	Else
		Return False
	EndIf
EndFunc

Func TurnInFaction()
	TravelTo(77) ;Outpost: HZH
	Waitmaploading(77)
	upd("Dumping Faction")
	$turnin = GetNearestNPCToCoords(5390, 1524)
	gotonpc($turnin)

	If BitAND(GUICtrlRead($Donate), $GUI_CHECKED) = $GUI_CHECKED Then
		Do
			upd("Donate")
			DonateFaction("Kurzick")
			RndSleep(250)
			GetKurzickFaction()
		Until GetKurzickFaction() < 5000
	EndIf
	
	If BitAND(GUICtrlRead($Amber), $GUI_CHECKED) = $GUI_CHECKED Then
		Do
		upd("Grabbing Amber")
		Dialog(0x800101)
		RndSleep(250)
		Until GetKurzickFaction() < 5000
	EndIf

	If BitAND(GUICtrlRead($Scrolls), $GUI_CHECKED) = $GUI_CHECKED Then
		Do
		upd("Grabbing Scrolls")
		Dialog(0x85)
		Dialog(0x800102)
		RndSleep(250)
		Until GetKurzickFaction() < 1000
	EndIf
	
	Sleep(500)
	TravelTo(349) ;Outpost: Anjeka Shrine
	Waitmaploading(349)
EndFunc

Func _PurgeHook()
	If not $rendering then
		ClearMemory()
		enableRendering()
		WinSetState(getWindowHandle(), "", @SW_SHOW)
		Sleep(1000)
		disableRendering()
		WinSetState(getWindowHandle(), "", @SW_HIDE)
   EndIf
EndFunc

#EndRegion Inventory
