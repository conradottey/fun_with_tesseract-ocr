require 'rubygems'
require 'rmagick'
# require 'ffi/aspell'
require 'raspell'

# @speller = FFI::Aspell::Speller.new('en_US')
@speller = Aspell.new("en_US")
@speller.suggestion_mode = Aspell::NORMAL
@image_size = 256
image_url = "images/smalltext.png"


def tessrack(oimg_name, do_gray=true, keep_temp=true)
   fname = oimg_name.chomp(File.extname(oimg_name))
   
   # create a non-crooked version of the image
   tiff = Magick::Image::read(oimg_name).first.deskew 

   # convert to grayscale if do_gray==true
   tiff = tiff.quantize(@image_size, Magick::GRAYColorspace) if do_gray == true
   
   # create a TIFF version of the file, as Tesseract only accepts TIFFs
   tname = "#{fname}--tesseracted.tif"
   tiff.write(tname){|t| t.depth = 16}
   puts "TR:\t#{tname} created"
    
   # Run tesseract
   tc = "tesseract #{tname} #{fname}"
   puts "TR:\t#{tc}"
   `#{tc}`
   
   File.delete(tname) unless keep_temp==true
   File.open("#{fname}.txt"){|txt| txt.read}
end

txt = tessrack(image_url)




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

def word_replace text
   # text = "my haert wil go on"
   text.gsub(/[\w\']+/) do |word| 
     if !@speller.check(word) 
       # word is wrong
       puts "Possible correction for #{word}:"
       puts @speller.suggest(word).first
     end
   end
end

word_replace txt
# word_checker parser_array