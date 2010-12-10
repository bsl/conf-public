import System.Exit
import System.IO                      (Handle)
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.Search
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName         (setWMName)
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Grid
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.WindowNavigation
import XMonad.Prompt
import XMonad.Prompt.Input
import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Util.Scratchpad

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

main :: IO ()
main = do
    xmobarPipe <- spawnPipe "xmobar"
    xmonad $ withUrgencyHook NoUrgencyHook $
      defaultConfig
        { terminal           = "urxvtc"
        , focusFollowsMouse  = True
        , modMask            = myModMask
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , keys               = myKeys
        , mouseBindings      = myMouseBindings
        , layoutHook         = myLayoutHook
        , manageHook         = myManageHook
        , logHook            = myLogHook xmobarPipe
        , startupHook        = myStartupHook
        }
  where
    myStartupHook =
        setWMName "LG3D"

myModMask :: KeyMask
myModMask = mod4Mask

myBorderWidth :: Dimension
myBorderWidth = 2

myWorkspaces :: [String]
myWorkspaces = map show ([1..6] :: [Int])

myNormalBorderColor :: String
myNormalBorderColor = "#000000"

myFocusedBorderColor :: String
myFocusedBorderColor = "#ffffff"

myPromptConfig :: XPConfig
myPromptConfig = defaultXPConfig
  { font              = "xft:Terminus"
  , bgColor           = "black"
  , fgColor           = "gray"
  , promptBorderWidth = myBorderWidth
  , borderColor       = "black"
  , historySize       = 0
  }

shellPrompt :: XPConfig -> X ()
shellPrompt c = inputPrompt c "Run" ?+ spawn

searchEngines :: [(String, SearchEngine)]
searchEngines =
    [ ("a"  , amazon)
    , ("c"  , codesearch)
    , ("d"  , dictionary)
    , ("g"  , google)
    , ("S-g", github)
    , ("S-h", hoogle)
    , ("h"  , hackage')
    , ("i"  , imagesEn)
    , ("l"  , arch)
    , ("S-l", archaur)
    , ("t"  , thesaurus)
    , ("w"  , wikipedia)
    , ("y"  , youtube)
    ]
  where
    arch     = searchEngine "Arch"     "http://www.archlinux.org/packages/?q="
    archaur  = searchEngine "Arch AUR" "http://aur.archlinux.org/packages.php?K="
    github   = searchEngine "github"   "http://github.com/search?x=0&y=0&q="
    imagesEn = searchEngine "images"   "http://images.google.com/images?q="
    hackage' = searchEngine "hackage"  "http://www.google.com/search?hl=en&as_sitesearch=hackage.haskell.org%2Fpackage&as_q="

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf = mkKeymap conf $
    [ ("M-0"                    , spawn "lock-screen")
    , ("M-i"                    , spawn $ XMonad.terminal conf ++ " -e tmux -u -2")
    , ("M-p"                    , shellPrompt myPromptConfig)
    , ("M-d"                    , windows $ W.greedyView "5")
    , ("M-w"                    , spawn "open-url-from-selection")

    , ("<XF86AudioLowerVolume>" , spawn "amixer -q set Master 2dB-")
    , ("<XF86AudioRaiseVolume>" , spawn "amixer -q set Master 2dB+")

    , ("M-y"                    , scratchpadSpawnActionCustom $ XMonad.terminal conf ++ " -name scratchpad -bg '#000018'")
    , ("M-o"                    , nextWS)
    , ("M-u"                    , prevWS)
    , ("M-q"                    , toggleWS)
    , ("M-l"                    , sendMessage $ Go R)
    , ("M-h"                    , sendMessage $ Go L)
    , ("M-k"                    , sendMessage $ Go U)
    , ("M-j"                    , sendMessage $ Go D)
    , ("M-C-l"                  , sendMessage $ Swap R)
    , ("M-C-h"                  , sendMessage $ Swap L)
    , ("M-C-k"                  , sendMessage $ Swap U)
    , ("M-C-j"                  , sendMessage $ Swap D)
    , ("M-f"                    , windows W.focusDown)
    , ("M-c"                    , kill)
    , ("M-<Space>"              , sendMessage NextLayout)
    , ("M-S-<Space>"            , setLayout $ XMonad.layoutHook conf)
    , ("M-S-k"                  , sendMessage Shrink)
    , ("M-S-j"                  , sendMessage Expand)
    , ("M-S-t"                  , withFocused $ windows . W.sink)
    , ("M-S-x"                  , io (exitWith ExitSuccess))
    , ("M-S-r"                  , spawn "xmonad-restart")
    , ("M-r"                    , restart "xmonad" True)
    ]
    ++ [("M-e " ++ k, promptSearchBrowser myPromptConfig "firefox" f) | (k,f) <- searchEngines]
    ++
    [ (m ++ k, windows $ f w)
    | (w, k) <- zip (XMonad.workspaces conf) (map show ([1..6] :: [Int]))
    , (m, f) <- [("M-", W.greedyView), ("M-S-", W.shift)]
    ]

-- crazy signature
myMouseBindings (XConfig { XMonad.modMask = m }) = M.fromList
    [ ((m, button1), (\w -> focus w >> mouseMoveWindow w))
    , ((m, button3), (\w -> focus w >> mouseResizeWindow w))
    ]

-- crazy signature
myLayoutHook =
    avoidStruts                              $
    smartBorders                             $
    configurableNavigation noNavigateBorders $
    onWorkspace "1" (tall ||| grid)          $
    onWorkspace "2" (tall ||| grid)          $
    onWorkspace "3" (full ||| tall ||| grid) $
    onWorkspace "4" (tall ||| grid)          $
    onWorkspace "5" (full ||| tall ||| grid) $
    onWorkspace "6" (tall ||| grid)          $ (tall ||| grid ||| full)
  where
    tall = Tall 1 (2/100) (1/2)
    grid = Grid
    full = Full

myManageHook :: ManageHook
myManageHook = composeAll
    [ scratchpadManageHook (W.RationalRect 0.04 0.04 0.6 0.4)
    , insertPosition Below Newer
    , manageDocks
    , title     =? "Namoroka"       --> doF (W.shift "3")
    , className =? "Evince"         --> doF (W.shift "5")
    , title     =? "OpenOffice.org" --> doF (W.shift "5")
    , className =? "scratchpad"     --> doFloat
    , className =? "MPlayer"        --> doFloat
    , title     =? "boomslang"      --> doFloat
    , title     =? "GLFW Window"    --> doFloat
    , className =? "Anki"           --> doFloat
    ]

myLogHook :: Handle -> X ()
myLogHook h =
    dynamicLogWithPP defaultPP
      { ppCurrent         = xmobarColor "#ffffff" "#2060ff" . pad
      , ppUrgent          = xmobarColor "#ffffff" "#ff0000" . xmobarStrip
      , ppHidden          = xmobarColor "#ffffff" "#003080" . pad
      , ppHiddenNoWindows = xmobarColor "#ffffff" "#000000" . pad
      , ppOrder           = \(ws:_) -> [ws]
      , ppOutput          = hPutStrLn h
      , ppWsSep           = ""
      , ppSort = fmap (.scratchpadFilterOutWorkspace) $ ppSort defaultPP
      }
