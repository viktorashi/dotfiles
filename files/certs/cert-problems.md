# Corporate Certificate Problems

If you're getting `tls: failed to verify certificate: x509: certificate signed by unknown authority` errors across everything (`yay`, `curl`, Python HTTP packages, `npm`, etc.), it's **not** because the certificates are old or not up to a newer x509 standard.

It's actually because your corporate network uses a **Man-in-the-Middle (MITM) proxy** for SSL inspection. 

When you try to connect to `https://aur.archlinux.org`, the corporate proxy intercepts the connection and dynamically generates a fake certificate for `aur.archlinux.org`, signed by the internal company Root CA (in this case, `STRATECProxy`).

Because your Linux machine (or WSL environment) has no idea who `STRATECProxy` is, it rightfully panics and rejects the certificate as an "unknown authority".

### The Fix

You *cannot* easily globally "relax" this in a secure way. While some tools have insecure flags (like `curl -k` or setting `NODE_TLS_REJECT_UNAUTHORIZED=0`), many modern tools (like Go binaries such as `yay`) explicitly forbid globally bypassing TLS for security reasons.

**The correct, permanent fix is exactly what you suspected:**
You need to download the corporate Root CA certificate (likely from Confluence or your IT portal) and install it into your system's trust store.

Once your system natively trusts the `STRATECProxy` Root CA, everything (`yay`, `curl`, Python, Node) will magically start working again without any complaints!

### How to install the cert (Arch Linux / Manjaro)
1. Download the `.crt` or `.pem` file from Confluence (e.g., `stratec-root-ca.crt`).
2. Copy it to the trust store directory:
   `sudo cp stratec-root-ca.crt /etc/ca-certificates/trust-source/anchors/`
3. Update the system trust store:
   `sudo trust extract-compat` (or `sudo update-ca-trust`)

*(For Ubuntu/Debian/WSL, copy to `/usr/local/share/ca-certificates/` and run `sudo update-ca-certificates`)*
