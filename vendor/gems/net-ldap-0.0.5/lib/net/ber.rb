# $Id$
#
# NET::BER
# Mixes ASN.1/BER convenience methods into several standard classes.
# Also provides BER parsing functionality.
#
#----------------------------------------------------------------------------
#
# Copyright (C) 2006 by Francis Cianfrocca. All Rights Reserved.
#
# Gmail: garbagecat10
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#---------------------------------------------------------------------------
#
#


module Net

  module BER

  class BerError < StandardError; end


  class BerIdentifiedString < String
    attr_accessor :ber_identifier
    def initialize args
      super args
    end
  end

  class BerIdentifiedArray < Array
    attr_accessor :ber_identifier
    def initialize
      super
    end
  end

  class BerIdentifiedNull
    attr_accessor :ber_identifier
    def to_ber
	"\005\000"
    end
  end

  class BerIdentifiedOid
    attr_accessor :ber_identifier
    def initialize oid
	if oid.is_a?(String)
	    oid = oid.split(/\./).map {|s| s.to_i }
	end
	@value = oid
    end
    def to_ber
	# Provisional implementation.
	# We ASSUME that our incoming value is an array, and we
	# use the Array#to_ber_oid method defined below.
	# We probably should obsolete that method, actually, in
	# and move the code here.
	# WE ARE NOT CURRENTLY ENCODING THE BER-IDENTIFIER.
	# This implementation currently hardcodes 6, the universal OID tag.
	ary = @value.dup
	first = ary.shift
	raise Net::BER::BerError.new(" invalid OID" ) unless [0,1,2].include?(first)
	first = first * 40 + ary.shift
	ary.unshift first
	oid = ary.pack("w*")
	[6, oid.length].pack("CC") + oid
    end
  end

  #--
  # This condenses our nicely self-documenting ASN hashes down
  # to an array for fast lookups.
  # Scoped to be called as a module method, but not intended for
  # user code to call.
  #
  def self.compile_syntax syn
    out = [nil] * 256
    syn.each {|tclass,tclasses|
      tagclass = {:universal=>0, :application=>64, :context_specific=>128, :private=>192} [tclass]
      tclasses.each {|codingtype,codings|
        encoding = {:primitive=>0, :constructed=>32} [codingtype]
        codings.each {|tag,objtype|
          out[tagclass + encoding + tag] = objtype
        }
      }
    }
    out
  end

  # This module is for mixing into IO and IO-like objects.
  module BERParser

    # The order of these follows the class-codes in BER.
    # Maybe this should have been a hash.
    TagClasses = [:universal, :application, :context_specific, :private]

    BuiltinSyntax = BER.compile_syntax( {
	:universal => {
	    :primitive => {
		1 => :boolean,
		2 => :integer,
		4 => :string,
		5 => :null,
		6 => :oid,
		10 => :integer,
		13 => :string # (relative OID)
	    },
	    :constructed => {
		16 => :array,
		17 => :array
	    }
	},
	:context_specific => {
	    :primitive => {
		10 => :integer
	    }
	}
    })

    #
    # read_ber
    # TODO: clean this up so it works properly with partial
    # packets coming from streams that don't block when
    # we ask for more data (like StringIOs). At it is,
    # this can throw TypeErrors and other nasties.
    #--
    # BEWARE, this violates DRY and is largely equal in functionality to
    # read_ber_from_string. Eventually that method may subsume the functionality
    # of this one.
    #
    def read_ber syntax=nil
      # don't bother with this line, since IO#getbyte by definition returns nil on eof.
      #return nil if eof?

      id = getbyte or return nil  # don't trash this value, we'll use it later
      #tag = id & 31
      #tag < 31 or raise BerError.new( "unsupported tag encoding: #{id}" )
      #tagclass = TagClasses[ id >> 6 ]
      #encoding = (id & 0x20 != 0) ? :constructed : :primitive

      n = getbyte
      lengthlength,contentlength = if n <= 127
        [1,n]
      else
        # Replaced the inject because it profiles hot.
        #j = (0...(n & 127)).inject(0) {|mem,x| mem = (mem << 8) + getbyte}
        j = 0
        read( n & 127 ).each_byte {|n1| j = (j << 8) + n1}
        [1 + (n & 127), j]
      end

      newobj = read contentlength

      # This exceptionally clever and clear bit of code is verrrry slow.
      objtype = (syntax && syntax[id]) || BuiltinSyntax[id]


      # == is expensive so sort this if/else so the common cases are at the top.
      obj = if objtype == :string
        #(newobj || "").dup
        s = BerIdentifiedString.new( newobj || "" )
        s.ber_identifier = id
        s
      elsif objtype == :integer
        j = 0
        newobj.each_byte {|b| j = (j << 8) + b}
        j
      elsif objtype == :oid
	  # cf X.690 pgh 8.19 for an explanation of this algorithm.
	  # Potentially not good enough. We may need a BerIdentifiedOid
	  # as a subclass of BerIdentifiedArray, to get the ber identifier
	  # and also a to_s method that produces the familiar dotted notation.
	  oid = newobj.unpack("w*")
	  f = oid.shift
	  g = if f < 40
	      [0, f]
	  elsif f < 80
	      [1, f-40]
	  else
	      [2, f-80] # f-80 can easily be > 80. What a weird optimization.
	  end
	  oid.unshift g.last
	  oid.unshift g.first
	  oid
      elsif objtype == :array
        #seq = []
        seq = BerIdentifiedArray.new
        seq.ber_identifier = id
        sio = StringIO.new( newobj || "" )
        # Interpret the subobject, but note how the loop
        # is built: nil ends the loop, but false (a valid
        # BER value) does not!
        while (e = sio.read_ber(syntax)) != nil
          seq << e
        end
        seq
      elsif objtype == :boolean
        newobj != "\000"
      elsif objtype == :null
	  n = BerIdentifiedNull.new
	  n.ber_identifier = id
	  n
      else
        #raise BerError.new( "unsupported object type: class=#{tagclass}, encoding=#{encoding}, tag=#{tag}" )
        raise BerError.new( "unsupported object type: id=#{id}" )
      end

      # Add the identifier bits into the object if it's a String or an Array.
      # We can't add extra stuff to Fixnums and booleans, not that it makes much sense anyway.
      # Replaced this mechanism with subclasses because the instance_eval profiled too hot.
      #obj and ([String,Array].include? obj.class) and obj.instance_eval "def ber_identifier; #{id}; end"
      #obj.ber_identifier = id if obj.respond_to?(:ber_identifier)
      obj

    end

	    #--
	    # Violates DRY! This replicates the functionality of #read_ber.
	    # Eventually this method may replace that one.
	    # This version of #read_ber behaves properly in the face of incomplete
	    # data packets. If a full BER object is detected, we return an array containing
	    # the detected object and the number of bytes consumed from the string.
	    # If we don't detect a complete packet, return nil.
	    #
	    # Observe that weirdly we recursively call the original #read_ber in here.
	    # That needs to be fixed if we ever obsolete the original method in favor of this one.
	    def read_ber_from_string str, syntax=nil
		id = str[0] or return nil
		n = str[1] or return nil
		n_consumed = 2
		lengthlength,contentlength = if n <= 127
		    [1,n]
		else
		    n1 = n & 127
		    return nil unless str.length >= (n_consumed + n1)
		    j = 0
		    n1.times {
			j = (j << 8) + str[n_consumed]
			n_consumed += 1
		    }
		    [1 + (n1), j]
		end

		return nil unless str.length >= (n_consumed + contentlength)
		newobj = str[n_consumed...(n_consumed + contentlength)]
		n_consumed += contentlength

		objtype = (syntax && syntax[id]) || BuiltinSyntax[id]

		# == is expensive so sort this if/else so the common cases are at the top.
		obj = if objtype == :array
		    seq = BerIdentifiedArray.new
		    seq.ber_identifier = id
		    sio = StringIO.new( newobj || "" )
		    # Interpret the subobject, but note how the loop
		    # is built: nil ends the loop, but false (a valid
		    # BER value) does not!
		    # Also, we can use the standard read_ber method because
		    # we know for sure we have enough data. (Although this
		    # might be faster than the standard method.)
		    while (e = sio.read_ber(syntax)) != nil
			seq << e
		    end
		    seq
		elsif objtype == :string
		    s = BerIdentifiedString.new( newobj || "" )
		    s.ber_identifier = id
		    s
		elsif objtype == :integer
		    j = 0
		    newobj.each_byte {|b| j = (j << 8) + b}
		    j
		elsif objtype == :oid
		    # cf X.690 pgh 8.19 for an explanation of this algorithm.
		    # Potentially not good enough. We may need a BerIdentifiedOid
		    # as a subclass of BerIdentifiedArray, to get the ber identifier
		    # and also a to_s method that produces the familiar dotted notation.
		    oid = newobj.unpack("w*")
		    f = oid.shift
		    g = if f < 40
			[0,f]
		    elsif f < 80
			[1, f-40]
		    else
			[2, f-80] # f-80 can easily be > 80. What a weird optimization.
		    end
		    oid.unshift g.last
		    oid.unshift g.first
		    oid
		elsif objtype == :boolean
		    newobj != "\000"
		elsif objtype == :null
		    n = BerIdentifiedNull.new
		    n.ber_identifier = id
		    n
		else
		    raise BerError.new( "unsupported object type: id=#{id}" )
		end

		[obj, n_consumed]
	    end

  end # module BERParser
  end # module BER

end # module Net


class IO
  include Net::BER::BERParser
end

require "stringio"
class StringIO
  include Net::BER::BERParser
end

begin
  require 'openssl'
  class OpenSSL::SSL::SSLSocket
    include Net::BER::BERParser
  end
rescue LoadError
# Ignore LoadError.
# DON'T ignore NameError, which means the SSLSocket class
# is somehow unavailable on this implementation of Ruby's openssl.
# This may be WRONG, however, because we don't yet know how Ruby's
# openssl behaves on machines with no OpenSSL library. I suppose
# it's possible they do not fail to require 'openssl' but do not
# create the classes. So this code is provisional.
# Also, you might think that OpenSSL::SSL::SSLSocket inherits from
# IO so we'd pick it up above. But you'd be wrong.
end



class String
    include Net::BER::BERParser
    def read_ber syntax=nil
	StringIO.new(self).read_ber(syntax)
    end
    def read_ber! syntax=nil
	obj,n_consumed = read_ber_from_string(self, syntax)
	if n_consumed
	    self.slice!(0...n_consumed)
	    obj
	else
	    nil
	end
    end
end

#----------------------------------------------


class FalseClass
  #
  # to_ber
  #
  def to_ber
    "\001\001\000"
  end
end


class TrueClass
  #
  # to_ber
  #
  def to_ber
    "\001\001\001"
  end
end



class Fixnum
  #
  # to_ber
  #
  def to_ber
    "\002" + to_ber_internal
  end

  #
  # to_ber_enumerated
  #
  def to_ber_enumerated
    "\012" + to_ber_internal
  end

  #
  # to_ber_length_encoding
  #
  def to_ber_length_encoding
    if self <= 127
      [self].pack('C')
    else
      i = [self].pack('N').sub(/^[\0]+/,"")
      [0x80 + i.length].pack('C') + i
    end
  end

  # Generate a BER-encoding for an application-defined INTEGER.
  # Example: SNMP's Counter, Gauge, and TimeTick types.
  #
  def to_ber_application tag
      [0x40 + tag].pack("C") + to_ber_internal
  end

  #--
  # Called internally to BER-encode the length and content bytes of a Fixnum.
  # The caller will prepend the tag byte.
  def to_ber_internal
    # PLEASE optimize this code path. It's awfully ugly and probably slow.
    # It also doesn't understand negative numbers yet.
    raise Net::BER::BerError.new( "range error in fixnum" ) unless self >= 0
    z = [self].pack("N")
    zlen = if self < 0x80
	1
    elsif self < 0x8000
	2
    elsif self < 0x800000
	3
    else
	4
    end
    [zlen].pack("C") + z[0-zlen,zlen]
  end
  private :to_ber_internal

end # class Fixnum


class Bignum

  def to_ber
    #i = [self].pack('w')
    #i.length > 126 and raise Net::BER::BerError.new( "range error in bignum" )
    #[2, i.length].pack("CC") + i

    # Ruby represents Bignums as two's-complement numbers so we may actually be
    # good as far as representing negatives goes.
    # I'm sure this implementation can be improved performance-wise if necessary.
    # Ruby's Bignum#size returns the number of bytes in the internal representation
    # of the number, but it can and will include leading zero bytes on at least
    # some implementations. Evidently Ruby stores these as sets of quadbytes.
    # It's not illegal in BER to encode all of the leading zeroes but let's strip
    # them out anyway.
    #
    sz = self.size
    out = "\000" * sz
    (sz*8).times {|bit|
	if self[bit] == 1
	    out[bit/8] += (1 << (bit % 8))
	end
    }

    while out.length > 1 and out[-1] == 0
	out.slice!(-1,1)
    end

    [2, out.length].pack("CC") + out.reverse
  end

end



class String
  #
  # to_ber
  # A universal octet-string is tag number 4,
  # but others are possible depending on the context, so we
  # let the caller give us one.
  # The preferred way to do this in user code is via to_ber_application_sring
  # and to_ber_contextspecific.
  #
  def to_ber code = 4
    [code].pack('C') + length.to_ber_length_encoding + self
  end

  #
  # to_ber_application_string
  #
  def to_ber_application_string code
    to_ber( 0x40 + code )
  end

  #
  # to_ber_contextspecific
  #
  def to_ber_contextspecific code
    to_ber( 0x80 + code )
  end

end # class String



class Array
  #
  # to_ber_appsequence
  # An application-specific sequence usually gets assigned
  # a tag that is meaningful to the particular protocol being used.
  # This is different from the universal sequence, which usually
  # gets a tag value of 16.
  # Now here's an interesting thing: We're adding the X.690
  # "application constructed" code at the top of the tag byte (0x60),
  # but some clients, notably ldapsearch, send "context-specific
  # constructed" (0xA0). The latter would appear to violate RFC-1777,
  # but what do I know? We may need to change this.
  #

  def to_ber                 id = 0; to_ber_seq_internal( 0x30 + id ); end
  def to_ber_set             id = 0; to_ber_seq_internal( 0x31 + id ); end
  def to_ber_sequence        id = 0; to_ber_seq_internal( 0x30 + id ); end
  def to_ber_appsequence     id = 0; to_ber_seq_internal( 0x60 + id ); end
  def to_ber_contextspecific id = 0; to_ber_seq_internal( 0xA0 + id ); end

  def to_ber_oid
    ary = self.dup
    first = ary.shift
    raise Net::BER::BerError.new( "invalid OID" ) unless [0,1,2].include?(first)
    first = first * 40 + ary.shift
    ary.unshift first
    oid = ary.pack("w*")
    [6, oid.length].pack("CC") + oid
  end

  private
  def to_ber_seq_internal code
    s = ''
    self.each{|x| s = s + x}
    [code].pack('C') + s.length.to_ber_length_encoding + s
  end


end # class Array


