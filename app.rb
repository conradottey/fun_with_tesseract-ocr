require 'rubygems'
require 'rmagick'
require 'ffi/aspell'
# require 'rapspell'
@speller = FFI::Aspell::Speller.new('en_US')

def tessrack(oimg_name, do_gray=true, keep_temp=true)
   fname = oimg_name.chomp(File.extname(oimg_name))
   
   # create a non-crooked version of the image
   tiff = Magick::Image::read(oimg_name).first.deskew 

   # convert to grayscale if do_gray==true
   tiff = tiff.quantize(256, Magick::GRAYColorspace) if do_gray == true
   
   # create a TIFF version of the file, as Tesseract only accepts TIFFs
   tname = "#{fname}--tesseracted.tif"
   tiff.write(tname){|t| t.depth = 8}
   puts "TR:\t#{tname} created"
    
   # Run tesseract
   tc = "tesseract #{tname} #{fname}"
   puts "TR:\t#{tc}"
   `#{tc}`
   
   File.delete(tname) unless keep_temp==true
   File.open("#{fname}.txt"){|txt| txt.read}
end

txt = tessrack("artofwar.png")




def parse text
   text.split(' ')
end

parser_array = parse txt #converts txt into an array

def word_checker text_array
   text_array.each do |check|
      if @speller.correct?(check)
         puts check + ' is a word!'
      else
         puts check + ' aignt a word bro'
      end
   end
end

word_checker parser_array