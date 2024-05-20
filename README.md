<p align="center">
  <a href="https://triweb.com">
    <img src="https://triweb.com/branding/triweb-logo-light-padding.png" height="96">
    <h3 align="center">triweb-relay</h3>
  </a>
</p>

<p align="center">
  The official relay server for <a href="https://triweb.com">triweb</a>.
  <br/>
  Use it to install and run the complete triweb platform on your own servers and infrastructure.  
</p>

<br/>
<hr/>
<br/>

## Usage

To setup and run triweb relay on a server, follow these steps:

1. Clone the repository,
2. Prepare the target server with:
    ```
    ./bin/deploy -s user@hostname:/path  
    ```
   <small>(replace `user@hostname:/path` with your real username, server address and path under which you plan to deploy triweb-relay, e.g., `john@server.net:/srv/triweb`)</small>

3. Deploy to the server with:
    ```
    ./bin/deploy user@hostname:/path  
    ```

Once done, you you can point you domain names at your own server instead of the `triweb.io` server.
For more details please see [triweb documentation](https://triweb.com/concepts/triweb-container.html#converting-a-domain-to-a-triweb-container).

## License

Please contact us on `support@triweb.com` for current licensing options.
