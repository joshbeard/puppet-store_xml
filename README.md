# store_xml

## Overview

store_xml is a report handler for Puppet that stores full reports in XML.

This is very similar to the built-in `store` report handler, but the output is
XML instead of YAML.

## Requirements

The `activesupport` Rubygem is required.

NOTE: activesupport requires the `builder` gem, but may not install it
automatically.  You'll may need to do this yourself.

## Usage

1.  Install the `activesupport` gem on your Puppet master

        $ sudo gem install activesupport

    On PE, use the PE vendored `gem`:

        $ sudo /opt/puppet/bin/gem install activesupport

    You may need to restart your Puppet Master service after installing the gem.
    If you see something like this:

        ... undefined method `to_xml' for #<Hash:0x007f1461193800>

    In your syslog, that's likely the culprit.

2.  You may need to manually install the `builder` gem if ActiveSupport didn't.

        $ sudo gem install builder

    On PE, use the PE vendored `gem`:

        $ sudo /opt/puppet/bin/gem install builder

3.  Install puppet-store_xml as a module in your Puppet master's module
    path.

4.  Run the Puppet agent on your master(s) to initiate `pluginsync`

5.  Enable the report handler by appending `store_xml` to the `reports` setting
    in the master's `puppet.conf` file under the `master` section.

The XML reports will be placed in `$reportdir/xml/$host`

On PE, that's `/var/opt/lib/pe-puppet/reports/xml/`

## Example Output

Check out the example in the `examples` directory to see sample output.

Feedback is welcome on how this should be formatted.

## Contributions

Yes, please.  This could be significantly improved and cleaned up.

## Authors

Josh Beard <beard@puppetlabs.com>
