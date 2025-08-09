# frozen_string_literal: true

# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
DROPBOX_EMAILS = {
  plain: <<~EMAIL,
    From: Aaron Assembler <aaron@example.com>
    To: Ben Bootloader <ben@example.com>
    Subject: Hi there
    Date: Mon, 26 May 2003 11:22:33 -0600
    Message-ID: <1234@local.machine.example>
    Content-Type: text/plain

    #{FFaker::Lorem.paragraph}

    Aaron
  EMAIL

  html: <<~EMAIL,
    From: Aaron Assembler <aaron@example.com>
    To: Ben Bootloader <ben@example.com>
    Subject: Hi there
    Date: Mon, 26 May 2003 11:22:33 -0600
    Message-ID: <1234@local.machine.example>
    Content-Type: text/html

    <html>
      <head></head>
      <body>
        <p>#{FFaker::Lorem.paragraph}</p>
        <p>Aaron</p>
      </body>
    </html>
  EMAIL

  first_line: <<~EMAIL,
    From: Aaron Assembler <aaron@example.com>
    To: Ben Bootloader <ben@example.com>
    Subject: Hi there
    Date: Mon, 26 May 2003 11:22:33 -0600
    Message-ID: <1234@local.machine.example>
    Content-Type: text/plain

    .campaign Got milk
    #{FFaker::Lorem.paragraph}

    Aaron
  EMAIL

  first_line_lead: <<~EMAIL,
    From: Aaron Assembler <aaron@example.com>
    To: Ben Bootloader <ben@example.com>
    Subject: Hi there
    Date: Mon, 26 May 2003 11:22:33 -0600
    Message-ID: <1234@local.machine.example>
    Content-Type: text/plain

    .lead Cindy Cluster
    #{FFaker::Lorem.paragraph}

    Aaron
  EMAIL

  first_line_contact: <<~EMAIL,
    From: Aaron Assembler <aaron@example.com>
    To: Ben Bootloader <ben@example.com>
    Subject: Hi there
    Date: Mon, 26 May 2003 11:22:33 -0600
    Message-ID: <1234@local.machine.example>
    Content-Type: text/plain

    .contact Cindy Cluster
    #{FFaker::Lorem.paragraph}

    Aaron
  EMAIL

  forwarded: <<~EMAIL,
    From: Aaron Assembler <aaron@example.com>
    To: dropbox@example.com
    Subject: Hi there
    Date: Mon, 26 May 2003 11:22:33 -0600
    Message-ID: <1234@local.machine.example>
    Content-Type: text/plain

    ---------- Forwarded message ----------
    From: Ben Bootloader <ben@example.com>
    Date: Sun, Mar 22, 2009 at 3:28 PM
    Subject: Fwd:
    To: Cindy Cluster <cindy@example.com>

    #{FFaker::Lorem.paragraph}

    Ben
  EMAIL

  multipart: <<~EMAIL
    From: Aaron Assembler <aaron@example.com>
    To: Ben Bootloader <ben@example.com>
    Subject: Hi there
    Date: Fri, 30 Mar 2012 15:04:05 +0800
    Message-ID: <1234@local.machine.example>
    Content-Type: multipart/related;
            boundary="_006_200DA2FF7EAFC04BAD979DB9CF293BB365151E88CLEARWATERtesta_";
            type="text/html"

    --_006_200DA2FF7EAFC04BAD979DB9CF293BB365151E88CLEARWATERtesta_
    Content-Type: text/html; charset="iso-8859-1"
    Content-Transfer-Encoding: quoted-printable

    <html>
    <head>
    <meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
    1">
    <meta name=3D"Generator" content=3D"Microsoft Word 14 (filtered medium)">
    <!--[if !mso]><style>v\:* {behavior:url(#default#VML);}
    o\:* {behavior:url(#default#VML);}
    w\:* {behavior:url(#default#VML);}
    .shape {behavior:url(#default#VML);}
    </style><![endif]--><style><!--
    /* Font Definitions */
    @font-face
            {font-family:Calibri;
            panose-1:2 15 5 2 2 2 4 3 2 4;}
    /* Style Definitions */
    p.MsoNormal, li.MsoNormal, div.MsoNormal
            {margin:0in;
            margin-bottom:.0001pt;
            font-size:11.0pt;
            font-family:"Calibri","sans-serif";}
    div.WordSection1
            {page:WordSection1;}
    --></style><!--[if gte mso 9]><xml>
    <o:shapedefaults v:ext=3D"edit" spidmax=3D"1026" />
    </xml><![endif]--><!--[if gte mso 9]><xml>
    <o:shapelayout v:ext=3D"edit">
    <o:idmap v:ext=3D"edit" data=3D"1" />
    </o:shapelayout></xml><![endif]-->
    </head>
    <body lang=3D"EN-US" link=3D"blue" vlink=3D"purple">
    <div class=3D"WordSection1">
    <p class=3D"MsoNormal"><span style=3D"color:#1F497D"><o:p>Hello,</o:p></spa=
    n></p>
    </div>
    </body>
    </html>

    --_006_200DA2FF7EAFC04BAD979DB9CF293BB365151E88CLEARWATERtesta_
    Content-Type: image/gif; name="image007.gif"
    Content-Description: image007.gif
    Content-Disposition: inline; filename="image007.gif"; size=633;
            creation-date="Fri, 30 Mar 2012 07:04:05 GMT";
            modification-date="Fri, 30 Mar 2012 07:04:05 GMT"
    Content-ID:<image007.gif@01CD0DBA.FB4A2170>
    Content-Transfer-Encoding: base64

    R0lGODlhXQASALMAAIiIiBESESIjIt3d3VVWVURFRLu7u2ZnZpmZmaqqqjM0M3d4d+7u7gABAMzM
    zP///yH5BAAAAAAALAAAAABdABIAAAT/8MlJ63Q2683tAAvTjdKwAFqyJBLQoGQsP0MgKGy3PuDi
    /4tHotHAWASN4MNRGMyeHYKAkshZGMnHQcFt3LhCr5IqhppH4IliXMGy3eRFQEQpELIS+oRR9Rgl
    VU4VBgmCFwkGFAxcdIshent4eZJhBi8Ulgh4QzkMd0QBElwLRCJyRA0HewqoiUsFqAIYQ6g4qKVt
    lHATQ55TEwQFu5wSBQEADB+iATgIWscMDC6qDwWyDAhONQUODA4KAQN8XIjjBH25b5S9mRIOL8MN
    LC5WanPulxOkGAIEFVJ6GATw9yCNKDaKdK1rIKJAAQkHpsRjISWDQReGHliiCG+CAGoTzAooEDVS
    DcJI6tj0CtPt2IOJBUtWMEgKEhYUnhq43KUvVEwKazTwfLmQTj8A92CKtCgTIyZ5F+6gCACyWEmD
    BU9OSkmGDlIF1GC6cAVUpiUYEkhlfCAgiLWAVEkCJXhFoUqGEwIU2QoI6qIACJIpwXoAmrQASg50
    G4LCQQBu3gjc+6lGwIA/KBPe1bOALkwasIj8wqoFFWKPqEA6QEKEmxqZQvTi1UxbEQebFRwkwJxh
    ADpMhSwQ4p2Bz9o8V84oX868ufPn0KNLn64hAgA7

    --_006_200DA2FF7EAFC04BAD979DB9CF293BB365151E88CLEARWATERtesta_--
  EMAIL
}
