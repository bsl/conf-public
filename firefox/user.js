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

/* Don't prevent me from browsing to unusual ports.
 */
user_pref("network.security.ports.banned.override", "1-65535");

/* Don't animate tabs.
 */
user_pref("browser.tabs.animate", false);

/* Improve SSL security.
 */
user_pref("security.tls.version.max", 3);
user_pref("security.ssl3.rsa_fips_des_ede3_sha", false);
