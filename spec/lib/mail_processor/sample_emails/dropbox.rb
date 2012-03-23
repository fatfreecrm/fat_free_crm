DROPBOX_EMAILS = {
  :plain => <<-END,
From: Aaron Assembler <aaron@example.com>
To: Ben Bootloader <ben@example.com>
Subject: Hi there
Date: Mon, 26 May 2003 11:22:33 -0600
Message-ID: <1234@local.machine.example>
Content-Type: text/plain

#{Faker::Lorem.paragraph}

Aaron
END

  :first_line => <<-END,
From: Aaron Assembler <aaron@example.com>
To: Ben Bootloader <ben@example.com>
Subject: Hi there
Date: Mon, 26 May 2003 11:22:33 -0600
Message-ID: <1234@local.machine.example>
Content-Type: text/plain

.campaign Got milk
#{Faker::Lorem.paragraph}

Aaron
END

  :first_line_lead => <<-END,
From: Aaron Assembler <aaron@example.com>
To: Ben Bootloader <ben@example.com>
Subject: Hi there
Date: Mon, 26 May 2003 11:22:33 -0600
Message-ID: <1234@local.machine.example>
Content-Type: text/plain

.lead Cindy Cluster
#{Faker::Lorem.paragraph}

Aaron
END

  :first_line_contact => <<-END,
From: Aaron Assembler <aaron@example.com>
To: Ben Bootloader <ben@example.com>
Subject: Hi there
Date: Mon, 26 May 2003 11:22:33 -0600
Message-ID: <1234@local.machine.example>
Content-Type: text/plain

.contact Cindy Cluster
#{Faker::Lorem.paragraph}

Aaron
END

  :forwarded => <<-END,
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

#{Faker::Lorem.paragraph}

Ben
END

}

