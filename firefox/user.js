/* Turn off domain guessing and keyword searches.
 */
user_pref("browser.fixup.alternate.enabled", false);
user_pref("keyword.enabled", false);

/* Don't send referrer.
 */
user_pref("network.http.sendRefererHeader", 0);

/* Don't close the window when the last tab is closed.
 */
user_pref("browser.tabs.closeWindowWithLastTab", false);
