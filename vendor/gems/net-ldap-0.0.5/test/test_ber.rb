# $Id: testber.rb 230 2006-12-19 18:27:57Z blackhedd $

require 'common'

class TestBer < Test::Unit::TestCase

	def test_encode_boolean
		assert_equal( "\x01\x01\x01", true.to_ber ) # should actually be: 01 01 ff
		assert_equal( "\x01\x01\x00", false.to_ber )
	end

	#def test_encode_nil
	#	assert_equal( "\x05\x00", nil.to_ber )
	#end

	def test_encode_integer

		# Fixnum
		#
		#assert_equal( "\x02\x02\x96\x46", -27_066.to_ber )
		#assert_equal( "\x02\x02\xFF\x7F", -129.to_ber )
		#assert_equal( "\x02\x01\x80", -128.to_ber )
		#assert_equal( "\x02\x01\xFF", -1.to_ber )

		assert_equal( "\x02\x01\x00", 0.to_ber )
		assert_equal( "\x02\x01\x01", 1.to_ber )
		assert_equal( "\x02\x01\x7F", 127.to_ber )
		assert_equal( "\x02\x02\x00\x80", 128.to_ber )
		assert_equal( "\x02\x02\x00\xFF", 255.to_ber )

		assert_equal( "\x02\x02\x01\x00", 256.to_ber )
		assert_equal( "\x02\x03\x00\xFF\xFF", 65535.to_ber )

		assert_equal( "\x02\x03\x01\x00\x00", 65536.to_ber )
		assert_equal( "\x02\x04\x00\xFF\xFF\xFF", 16_777_215.to_ber )

		assert_equal( "\x02\x04\x01\x00\x00\x00", 0x01000000.to_ber )
		assert_equal( "\x02\x04\x3F\xFF\xFF\xFF", 0x3FFFFFFF.to_ber )

		# Bignum
		#
		assert_equal( "\x02\x04\x4F\xFF\xFF\xFF", 0x4FFFFFFF.to_ber )
		#assert_equal( "\x02\x05\x00\xFF\xFF\xFF\xFF", 0xFFFFFFFF.to_ber )
	end

	# TOD Add some much bigger numbers
	# 5000000000 is a Bignum, which hits different code.
	def test_ber_integers
		assert_equal( "\002\001\005", 5.to_ber )
		assert_equal( "\002\002\001\364", 500.to_ber )
		assert_equal( "\002\003\0\303P", 50000.to_ber )
		assert_equal( "\002\005\001*\005\362\000", 5000000000.to_ber )
	end

	def test_ber_bignums
		# Some of these values are Fixnums and some are Bignums. Different BER code.
		[
			5,
			50,
			500,
			5000,
			50000,
			500000,
			5000000,
			50000000,
			500000000,
			1000000000,
			2000000000,
			3000000000,
			4000000000,
			5000000000
		].each {|val|
			assert_equal( val, val.to_ber.read_ber )
		}
	end

	def test_ber_parsing
		assert_equal( 6, "\002\001\006".read_ber( Net::LDAP::AsnSyntax ))
		assert_equal( "testing", "\004\007testing".read_ber( Net::LDAP::AsnSyntax ))
	end

	def test_ber_parser_on_ldap_bind_request
		require 'stringio'

		s = StringIO.new(
			"0$\002\001\001`\037\002\001\003\004\rAdministrator\200\vad_is_bogus" )

		assert_equal(
			[1, [3, "Administrator", "ad_is_bogus"]],
			s.read_ber( Net::LDAP::AsnSyntax ))
	end

	def test_oid
		oid = Net::BER::BerIdentifiedOid.new( [1,3,6,1,2,1,1,1,0] )
		assert_equal( "\006\b+\006\001\002\001\001\001\000", oid.to_ber )

		oid = Net::BER::BerIdentifiedOid.new( "1.3.6.1.2.1.1.1.0" )
		assert_equal( "\006\b+\006\001\002\001\001\001\000", oid.to_ber )
	end
end
