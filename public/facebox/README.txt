Facebox for Prototype, version 2.0
By Robert Gaal - http://wakoopa.com 
--------------------------------------------------------------------------

Heavily based on Facebox by Chris Wanstrath - http://famspam.com/facebox
First ported to Prototype by Phil Burrows - http://blog.philburrows.com

Licensed under the MIT:
http://www.opensource.org/licenses/mit-license.php

Need help?  Join the Google Groups mailing list:
http://groups.google.com/group/facebox/

--------------------------------------------------------------------------

Dependencies:   prototype & script.aculo.us + images & CSS files from original facebox
Usage:          Append 'rel="facebox"' to an element to call it inside a so-called facebox.

                You can also call it directly through the following code:
                
                facebox.loading();
                facebox.reveal('Facebox contents here', null);
                new Effect.Appear(facebox.facebox, {duration: .3});