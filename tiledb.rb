class Tiledb < Formula
    desc "Storage management library for sparse and dense array data"
    homepage "http://tiledb.io"
    url "https://github.com/TileDB-Inc/TileDB/archive/1.7.0.tar.gz"
    sha256 "bf8a689dd485c0f13b4173fe1f1a573230af2dc3c329329846becab22af48e10"
    version "1.7.0"
	
    head "https://github.com/TileDB-Inc/TileDB.git", :branch => "dev"

    option "with-debug", "Enables building with debug information"
    option "with-verbose", "Enables building with verbose status messages"
    option "with-no-serialization", "Disables building with REST serialization support"

    depends_on "cmake" => :build
    depends_on "tbb"
    depends_on "lzlib"
    depends_on "lz4"
    depends_on "bzip2"
    depends_on "zstd"

    def install
	# Build and install TileDB
	mkdir "build"
	cd "build" do
	    args = %W[
	      --prefix=#{prefix}
              --enable-s3
	      --enable-hdfs
	      --disable-tests
            ]
	    args << "--enable-debug" if build.with? "debug"
	    args << "--enable-verbose" if build.with? "verbose"
	    args << "--enable-serialization" unless build.with? "no-serialization"

            system "../bootstrap", *args

	    system "make"
	    system "make", "-C", "tiledb"
	    system "make", "-C", "tiledb", "install"
	end
    end

    test do
        (testpath/"test_tiledb.cpp").write <<~EOS
            #include "tiledb/tiledb.h"
	    #include "assert.h"
	    int main() {
	        int major = 0;
		int minor = 0;
		int patch = 0;
		tiledb_version(&major,&minor,&patch);
		return 0;
	    }
	EOS
	system ENV.cc, "test_tiledb.cpp", "-L#{lib}", "-ltiledb", "-o", "test"
	system "./test"
    end
end
