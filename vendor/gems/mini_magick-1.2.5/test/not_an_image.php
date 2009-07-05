<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html dir="ltr"><head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"><title>TextDrive Community Forum / Lighttpd says Insufficient memory (case 4)</title>

<link rel="stylesheet" type="text/css" href="not_an_image_files/Oxygen.css">
<script type="text/javascript">
<!--
function process_form(the_form)
{
  var element_names = new Object()
  element_names["req_message"] = "Message"

  if (document.all || document.getElementById)
  {
    for (i = 0; i < the_form.length; ++i)
    {
      var elem = the_form.elements[i]
      if (elem.name && elem.name.substring(0, 4) == "req_")
      {
        if (elem.type && (elem.type=="text" || elem.type=="textarea" || elem.type=="password" || elem.type=="file") && elem.value=='')
        {
          alert("\"" + element_names[elem.name] + "\" is a required field in this form.")
          elem.focus()
          return false
        }
      }
    }
  }

  return true
}
// -->
</script>
<style type="text/css">

body
{
  margin: 0px;
  padding: 0px;
}

#header
{
  margin: 0;
  padding: 0;
  height: 100px;
  text-align: left;
  background-color: #003;
}

#navlinks 
{
  font: 10px Verdana, Arial, Helvetica, sans-serif;
  color: #333333;
  padding: 10px;
  
}
</style></head>


<body>
<div id="header"><a href="http://textdrive.com/"><img src="not_an_image_files/textdrive_head.gif" style="border: 0pt none ;" alt="TextDrive" height="100" width="600"></a></div>
<div id="punwrap">
<div id="punviewtopic" class="pun">

<div id="brdheader" class="block">
  <div class="box">
    <div id="brdmenui" class="inbox">
      <ul>
        <li id="navindex"><a href="http://forum.textdrive.com/index.php">Index</a></li>
        <li id="navuserlist"><a href="http://forum.textdrive.com/userlist.php">User list</a></li>
        <li id="navsearch"><a href="http://forum.textdrive.com/search.php">Search</a></li>
        <li id="navprofile"><a href="http://forum.textdrive.com/profile.php?id=1067">Profile</a></li>
        <li id="navlogout"><a href="http://forum.textdrive.com/login.php?action=out&amp;id=1067">Logout</a></li>
      </ul>
    </div>
    <div id="brdwelcome" class="inbox">
      <ul class="conl">
        <li>Logged in as <strong>geography</strong></li>
        <li>Last visit: Today 21:29:23</li>
      </ul>
      <div class="clearer"></div>
    </div>
  </div>
</div>



<div class="linkst">
  <div class="inbox">
    <p class="pagelink conl">Pages: <strong>1</strong></p>
    <p class="postlink conr"><a href="http://forum.textdrive.com/post.php?tid=7356">Post reply</a></p>
    <ul><li><a href="http://forum.textdrive.com/index.php">Index</a></li><li>&nbsp;»&nbsp;<a href="http://forum.textdrive.com/viewforum.php?id=4">Troubleshooting</a></li><li>&nbsp;»&nbsp;Lighttpd says Insufficient memory (case 4)</li></ul>
    <div class="clearer"></div>
  </div>
</div>

<div id="p62698" class="blockpost rowodd firstpost">
  <h2><span><span class="conr">#1&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62698#p62698">Yesterday 20:47:30</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=1067">geography</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"></dd>
          <dd>From: NYC</dd>
          <dd>Registered: 2005-03-17</dd>
          <dd>Posts: 10</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=1067">E-mail</a>&nbsp;&nbsp;<a href="http://journal.gleepglop.com/">Website</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3>Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p>I
have a rails app that downloads images found on the web. I'm running it
through lighttpd and everything works fine unless it is a large image
(Like over 500k).</p>

  <p>Then lighttpd throughs this error:</p>
    Insufficient memory (case 4)

  <p>Has anyone else encountered this? What exactly could be the root of this error?</p>


 
        </div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p><strong>Online</strong></p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62698">Report</a> | </li><li class="postedit"><a href="http://forum.textdrive.com/edit.php?id=62698">Edit</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62698">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div id="p62708" class="blockpost roweven">
  <h2><span><span class="conr">#2&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62708#p62708">Yesterday 22:06:50</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=2707">jqshenker</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"><img src="not_an_image_files/2707.jfif" alt="" height="60" width="60"></dd>
          <dd>From: Palo Alto, CA</dd>
          <dd>Registered: 2005-09-06</dd>
          <dd>Posts: 422</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=2707">E-mail</a>&nbsp;&nbsp;<a href="http://nothingmuch.textdriven.com/">Website</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3> Re: Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p>Yeah,
it's the limits. Are you downloading it, or resizing it as well?
Downloading usually isn't the problem, it's the resizing that breaks.</p>


 
        </div>
        <div class="postsignature"><hr><a href="http://soggyslides.textdriven.com/">soggyslides - {abstractisms daily}</a></div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p>Offline</p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62708">Report</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62708">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div id="p62709" class="blockpost rowodd">
  <h2><span><span class="conr">#3&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62709#p62709">Yesterday 22:12:28</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=1045">julik</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"><img src="not_an_image_files/1045.png" alt="" height="60" width="57"></dd>
          <dd>From: Utrecht, Netherlands</dd>
          <dd>Registered: 2005-03-12</dd>
          <dd>Posts: 137</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=1045">E-mail</a>&nbsp;&nbsp;<a href="http://live.julik.nl/">Website</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3> Re: Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p>that doesn't feel well</p>


 
        </div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p><strong>Online</strong></p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62709">Report</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62709">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div id="p62732" class="blockpost roweven">
  <h2><span><span class="conr">#4&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62732#p62732">Today 03:46:42</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=1067">geography</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"></dd>
          <dd>From: NYC</dd>
          <dd>Registered: 2005-03-17</dd>
          <dd>Posts: 10</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=1067">E-mail</a>&nbsp;&nbsp;<a href="http://journal.gleepglop.com/">Website</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3> Re: Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p>I'm resizing it too. But that is not where it dies.<br>
It dies right before I write it to disk (With Magick::Image.write from RMagick)</p>


 
        </div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p><strong>Online</strong></p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62732">Report</a> | </li><li class="postdelete"><a href="http://forum.textdrive.com/delete.php?id=62732">Delete</a> | </li><li class="postedit"><a href="http://forum.textdrive.com/edit.php?id=62732">Edit</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62732">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div id="p62735" class="blockpost rowodd">
  <h2><span><span class="conr">#5&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62735#p62735">Today 04:14:08</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=2707">jqshenker</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"><img src="not_an_image_files/2707.jfif" alt="" height="60" width="60"></dd>
          <dd>From: Palo Alto, CA</dd>
          <dd>Registered: 2005-09-06</dd>
          <dd>Posts: 422</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=2707">E-mail</a>&nbsp;&nbsp;<a href="http://nothingmuch.textdriven.com/">Website</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3> Re: Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p></p><blockquote><div class="incqbox"><h4>geography wrote:</h4><p>I'm resizing it too. But that is not where it dies.<br>
It dies right before I write it to disk (With Magick::Image.write from RMagick)</p></div></blockquote><p><br>
I meant "resizing" as anything to do with RMagick. There've been a
couple threads on this, search around. Resizing you image before upload
or not using RMagick and instead using ImageMagick via the commandline
might or might not work.... basically you can't do much, unfortunately.</p>


 
        </div>
        <div class="postsignature"><hr><a href="http://soggyslides.textdriven.com/">soggyslides - {abstractisms daily}</a></div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p>Offline</p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62735">Report</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62735">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div id="p62737" class="blockpost roweven">
  <h2><span><span class="conr">#6&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62737#p62737">Today 04:17:28</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=1097">cch</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"></dd>
          <dd>Registered: 2005-03-21</dd>
          <dd>Posts: 108</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=1097">E-mail</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3> Re: Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p>what if  you use open(fname, 'w'){|f|f.write img.to_blob} ?</p>


 
        </div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p>Offline</p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62737">Report</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62737">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div id="p62767" class="blockpost rowodd">
  <h2><span><span class="conr">#7&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62767#p62767">Today 15:44:42</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=1067">geography</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"></dd>
          <dd>From: NYC</dd>
          <dd>Registered: 2005-03-17</dd>
          <dd>Posts: 10</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=1067">E-mail</a>&nbsp;&nbsp;<a href="http://journal.gleepglop.com/">Website</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3> Re: Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p>Using
open(fname, 'w'){|f|f.write img.to_blob} has the same problem... I
guess I'll try and run it from the command line but that seems like a
drastic step. Why is the memory so limited, shouldn't the server be
able to save 500k files, or does imageMagick have a very high overhead?</p>


 
        </div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p><strong>Online</strong></p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62767">Report</a> | </li><li class="postdelete"><a href="http://forum.textdrive.com/delete.php?id=62767">Delete</a> | </li><li class="postedit"><a href="http://forum.textdrive.com/edit.php?id=62767">Edit</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62767">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div id="p62774" class="blockpost roweven">
  <h2><span><span class="conr">#8&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62774#p62774">Today 17:03:28</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=2707">jqshenker</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"><img src="not_an_image_files/2707.jfif" alt="" height="60" width="60"></dd>
          <dd>From: Palo Alto, CA</dd>
          <dd>Registered: 2005-09-06</dd>
          <dd>Posts: 422</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=2707">E-mail</a>&nbsp;&nbsp;<a href="http://nothingmuch.textdriven.com/">Website</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3> Re: Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p>RMagick
does leak memory in some versions (there's a patched version of
file_column which resizes via the commandline), but I'm not sure why
you can't resize larger images. It doesn't take <strong>that</strong> much memory.</p>


 
        </div>
        <div class="postsignature"><hr><a href="http://soggyslides.textdriven.com/">soggyslides - {abstractisms daily}</a></div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p>Offline</p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62774">Report</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62774">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div id="p62782" class="blockpost rowodd">
  <h2><span><span class="conr">#9&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62782#p62782">Today 19:04:21</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=1067">geography</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"></dd>
          <dd>From: NYC</dd>
          <dd>Registered: 2005-03-17</dd>
          <dd>Posts: 10</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=1067">E-mail</a>&nbsp;&nbsp;<a href="http://journal.gleepglop.com/">Website</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3> Re: Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p>So what i've learned so far...</p>

  <p>TextDrive has a memory limit.<br>
-When using RMagick in a rails app running with fcgi and lighttpd this memory limit is exceeded.<br>
-When the memory limit is exceeded the fcgi process is killed (No expcetions caught or anything in Ruby... the process ends)<br>
-The problem occurs when writing images to disk (With either File.open or Image.write)<br>
-The problem still occurs if I call GC.starts after RMagick calls</p>

  <p>Here is what I don't get...<br>
-Why is the memory limit so low (Or why does a simple RMagick call take
up so much memory? My dispatch procs take up around 50 megs, I can't
imagine that opening a 600k file would come close to using that much
memory)<br>
-Would putting my RMagick code in a different thread allow me to have more memory at my disposal?</p>


 
        </div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p><strong>Online</strong></p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62782">Report</a> | </li><li class="postdelete"><a href="http://forum.textdrive.com/delete.php?id=62782">Delete</a> | </li><li class="postedit"><a href="http://forum.textdrive.com/edit.php?id=62782">Edit</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62782">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div id="p62785" class="blockpost roweven">
  <h2><span><span class="conr">#10&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62785#p62785">Today 19:29:11</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=1097">cch</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"></dd>
          <dd>Registered: 2005-03-21</dd>
          <dd>Posts: 108</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=1097">E-mail</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3> Re: Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p>the memory limit is 100mb.</p>

  <p>watch
your process as you make the upload to see how high it goes. also try
resizing an image using a standalone (no rails) ruby script and see how
much memory it uses this way.</p>


 
        </div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p>Offline</p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62785">Report</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62785">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div id="p62796" class="blockpost rowodd">
  <h2><span><span class="conr">#11&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62796#p62796">Today 21:13:19</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=1067">geography</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"></dd>
          <dd>From: NYC</dd>
          <dd>Registered: 2005-03-17</dd>
          <dd>Posts: 10</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=1067">E-mail</a>&nbsp;&nbsp;<a href="http://journal.gleepglop.com/">Website</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3> Re: Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p>So after some investigation it seems like RMagick is a total memory hog.</p>

  <p>I load a 750k image with this tiny standalone ruby program...</p>

  <p>image = nil<br>
open(filepath) do |f|</p>
  image = Magick::Image.from_blob(f.read).first<br>
end<br>
image.write("image.jpg")

  <p>Monitoring the mem usage (using top) I get this 8th column is mem usuage</p>
  <p>#File being downloaded<br>
7198 ruby          7.6%  0:04.83   2    15    60  3.37M+ 2.65M  4.88M+ 44.5M+<br>
7198 ruby        14.4%  0:05.01   2    15    68  18.1M+ 2.73M+ 20.0M+ 80.9M+<br>
7198 ruby        35.0%  0:05.49   2    15    67  41.8M+ 2.73M  43.7M+ 80.8M-</p>
  <p>#File being loading into Magick::Image<br>
7198 ruby          0.1%  0:05.49   2    15    67  41.8M   2.73M  43.7M  80.8M-<br>
7198 ruby          0.1%  0:05.49   2    15    67  41.8M   2.73M  43.7M  80.8M-</p>
  <p>#File being written to disk<br>
7198 ruby          3.4%  0:05.53   2    15    72  43.4M+ 2.73M  45.3M+  122M+<br>
7198 ruby        55.9%  0:06.29   2    15    72  61.1M+ 2.73M  63.0M+  122M <br>
7198 ruby        48.4%  0:06.93   2    15    72  76.1M+ 2.73M  78.1M+  122M <br>
7198 ruby        48.2%  0:07.55   2    15    67  42.5M-  2.73M  44.4M- 80.8M-</p>

  <p>So
I guess the moral is RMagick eats up a ton of memory. I can't really
see anyway around this problem though, maybe using the command line
would eat up less memory (which is what I'll try next)</p>


 
          <p class="postedit"><em>Last edited by geography (Today 21:29:17)</em></p>
        </div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p><strong>Online</strong></p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62796">Report</a> | </li><li class="postdelete"><a href="http://forum.textdrive.com/delete.php?id=62796">Delete</a> | </li><li class="postedit"><a href="http://forum.textdrive.com/edit.php?id=62796">Edit</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62796">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div id="p62801" class="blockpost roweven">
  <h2><span><span class="conr">#12&nbsp;</span><a href="http://forum.textdrive.com/viewtopic.php?pid=62801#p62801">Today 21:55:36</a></span></h2>
  <div class="box">
    <div class="inbox">
      <div class="postleft">
        <dl>
          <dt><strong><a href="http://forum.textdrive.com/profile.php?id=1097">cch</a></strong></dt>
          <dd class="usertitle"><strong>Member</strong></dd>
          <dd class="postavatar"></dd>
          <dd>Registered: 2005-03-21</dd>
          <dd>Posts: 108</dd>
          <dd class="usercontacts"><a href="http://forum.textdrive.com/misc.php?email=1097">E-mail</a></dd>
        </dl>
      </div>
      <div class="postright">
        <h3> Re: Lighttpd says Insufficient memory (case 4)</h3>
        <div class="postmsg">
            <p>Yea, now you have to know whether it's RMagick specifically, or ImageMagick itself that is a memory hog.</p>

  <p>I
suppose it goes memory hungry because it expands a full uncompressed
24bit bitmap to memory, and that's innevitably large. (entirely
uninformed hunch)</p>

  <p>There's ruby-GD as an alternative, but it
doesn't look nearly as nice, and I've never used it, and I don't know
if it'd be more or less of a hog.</p>


 
          <p class="postedit"><em>Last edited by cch (Today 21:56:17)</em></p>
        </div>
      </div>
      <div class="clearer"></div>
      <div class="postfootleft"><p>Offline</p></div>
      <div class="postfootright"><ul><li class="postreport"><a href="http://forum.textdrive.com/misc.php?report=62801">Report</a> | </li><li class="postquote"><a href="http://forum.textdrive.com/post.php?tid=7356&amp;qid=62801">Quote</a></li></ul></div>
    </div>
  </div>
</div>

<div class="postlinksb">
  <div class="inbox">
    <p class="postlink conr"><a href="http://forum.textdrive.com/post.php?tid=7356">Post reply</a></p>
    <p class="pagelink conl">Pages: <strong>1</strong></p>
    <ul><li><a href="http://forum.textdrive.com/index.php">Index</a></li><li>&nbsp;»&nbsp;<a href="http://forum.textdrive.com/viewforum.php?id=4">Troubleshooting</a></li><li>&nbsp;»&nbsp;Lighttpd says Insufficient memory (case 4)</li></ul>
    <p class="subscribelink clearb">You are currently subscribed to this topic - <a href="http://forum.textdrive.com/misc.php?unsubscribe=7356">Unsubscribe</a></p>
  </div>
</div>

<div class="blockform">
  <h2><span>Quick post</span></h2>
  <div class="box">
    <form method="post" action="post.php?tid=7356" onsubmit="this.submit.disabled=true;if(process_form(this)){return true;}else{this.submit.disabled=false;return false;}">
      <div class="inform">
        <fieldset>
          <legend>Write your message and submit <span style="color: red; text-decoration: underline;">keeping in mind that this is not an official support forum.</span></legend>
          <div class="infldset txtarea">
            <input name="form_sent" value="1" type="hidden">
            <input name="form_user" value="geography" type="hidden">
            <label><textarea name="req_message" rows="7" cols="75" tabindex="1"></textarea></label>
            <ul class="bblinks">
              <li><a href="http://forum.textdrive.com/help.php#bbcode" onclick="window.open(this.href); return false;">BBCode</a>: on</li>
              <li><a href="http://forum.textdrive.com/help.php#img" onclick="window.open(this.href); return false;">[img] tag</a>: on</li>
              <li><a href="http://forum.textdrive.com/help.php#smilies" onclick="window.open(this.href); return false;">Smilies</a>: off</li>
            </ul>
          </div>
        </fieldset>
      </div>
      <p><input name="submit" tabindex="2" value="Submit" accesskey="s" type="submit"></p>
    </form>
  </div>
</div>

<div id="brdfooter" class="block">
  <h2><span>Board footer</span></h2>
  <div class="box">
    <div class="inbox">

      <div class="conl">
        <form id="qjump" method="get" action="viewforum.php">
          <div><label>Jump to
          <br><select name="id" onchange="window.location=('viewforum.php?id='+this.options[this.selectedIndex].value)"><optgroup label="TextDrive Hosting"><option value="2">Announcements</option><option value="33">Questions and Stuff</option><option value="11">Why Host With TXD?</option><option value="1">Getting Started</option><option value="3">How Do I...?</option><option value="4" selected="selected">Troubleshooting</option><option value="15">SPAM and Security</option><option value="5">Coding in General</option><option value="16">Localhostin'</option><option value="31">Look What I Did Dammit</option><option value="6">TextDrivel</option><option value="8">Archives</option><option value="32">Designing yourself into a corner</option></optgroup><optgroup label="TextDrive Internationale"><option value="23">TextDrive En Español</option><option value="24">TextDrive en Français</option></optgroup><optgroup label="Applications (and their developers) on TextDrive"><option value="7">Textpattern</option><option value="9">RubyOnRails</option><option value="10">Instiki</option><option value="12">Photostack</option><option value="13">PunBB</option><option value="14">WordPress</option><option value="17">Epilog</option><option value="20">sIFR</option><option value="22">Subversion</option><option value="26">Lightpress</option><option value="27">Loudblog</option><option value="25">Strongspace</option><option value="29">RailsAppHosting</option><option value="35">Anemone</option><option value="28">Django</option><option value="30">TurboGears</option><option value="34">Templation</option></optgroup></select>
          <input value=" Go " accesskey="g" type="submit">
          </label></div>
        </form>
      </div>
      <p class="conr">Powered by <a href="http://www.punbb.org/">PunBB</a><br>© Copyright 2002–2005 Rickard Andersson</p>
      <div class="clearer"></div>
    </div>
  </div>
</div>

</div>
</div>

</body></html>