class Tiledb < Formula
    desc "Storage management library for sparse and dense array data"
    homepage "http://tiledb.io"
    url "https://github.com/TileDB-Inc/TileDB/archive/1.4.1.tar.gz"
    sha256 "a278ebef1acc6e329eb9816502dda6b3c8b35c4853745a222111626c251b2845"
    version "1.4.1"
	
    head "https://github.com/TileDB-Inc/TileDB.git", :branch => "dev"

    option "with-debug", "Enables building with debug information"
    option "with-verbose", "Enables building with verbose status messages"
    option "with-s3", "Enables building with S3 backend support"
    option "with-hdfs", "Enables bulding with HDFS backend suport"

    depends_on "cmake" => :build
    depends_on "aws-sdk-cpp"
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
	      --disable-tests
            ]
	    args << "--enable-debug" if build.with? "debug"
	    args << "--enable-verbose" if build.with? "verbose"
	    args << "--enable-s3" if build.with? "s3"
	    args << "--enable-hdfs" if build.with? "hdfs"

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
