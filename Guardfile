# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'minitest', cli: "--seed 123456 --verbose" do
  # with Minitest::Unit
  watch(%r|^test/test_helper\.rb|)     { "test" }

  watch(%r|^test/functional/(.*)\.rb|) { |m| "test/functional/#{m[1]}.rb" }
  watch(%r|^test/unit/(.*)\.rb|)       { |m| "test/unit/#{m[1]}.rb" }

  watch(%r|^app/controllers/(.*)\.rb|) { |m| "test/functional/#{m[1]}_test.rb" }
  watch(%r|^app/helpers/(.*)\.rb|)     { |m| "test/helpers/#{m[1]}_test.rb" }
  watch(%r|^app/models/(.*)\.rb|)      { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r|^lib/(.*)\.rb|)             { |m| "test/unit/#{m[1]}_test.rb" }
end
