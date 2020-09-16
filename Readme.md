rgmac
=====

A random MAC address generator

## Usage:

```
Usage: rgmac [OPTION]...
A random MAC address generator

  e.g. rgmac                          -- Locally administered address (Like WiFi MAC Randomization)
  e.g. rgmac -us 3C:E0:72             -- Make a Apple MAC with Uppercase (Fake MAC)
  e.g. rgmac -ac -t console:Sony      -- Make a SonyPS MAC (Fake MAC)

Options:
  -a, --format <outformat>            -- Format for MAC output
  -u, --upcase                        -- Uppercase MAC output
  -s, --assign <xx:xx:xx>             -- Specify OUI manually
  -e, --query <xx:xx:xx>              -- Query the OUI of the MAC address
  -t, --device <VendorType:NameID>    -- Use IEEE public OUI, See 'Vendor/<VendorType>.txt'
  -l, --list[VendorType]              -- List valid VendorType and NameID
  -U, --update                        -- Update locale OUI database
  -V, --version                       -- Returns version
  --help                              -- Returns help info

OptFormat:
  <xx:xx:xx>    Valid: 06fcee, 06-fc-ee, 06:fc:ee, 06fcee5f3355, 06-fc-ee-5f-33-55, 06:fc:ee:5f:33:55
  <outformat>   Valid: (C)olon, (D)ash
```

## License:

[MIT License](./LICENSE)
