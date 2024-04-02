# file_generation_service.rb
require 'json'
require 'fileutils'

module FileGenerationService
  # Generates project files from the specified languages and API response
  def self.generate_files(project_location, response, languages)
    puts project_location, response, languages
    file_paths = generate_file_paths(languages)
    FileUtils.mkdir_p(project_location) unless Dir.exist?(project_location)

    file_paths.each do |file_name, lang|
      file_content = extract_content_for_language(response, lang)
      next if file_content.nil? || file_content.empty?

      file_path = File.join(project_location, file_name)
      File.write(file_path, file_content)
      puts "Generated file: #{file_path}"
    end
    puts "File generation completed successfully."
    return true
  end

  private

  # Maps specified languages to filenames
  def self.generate_file_paths(languages)
    paths = {}
    # Adjusted to handle the new hash format for languages
    programming_lang = languages["programming"]
    style_lang = languages["style"]

    # Handle programming languages
    case programming_lang
    when 'html'
      paths['index.html'] = programming_lang
    when 'html+javascript'
      paths['index.html'] = programming_lang #Need to find a way to separate javascript file
    when 'html+typescript'
      paths['index.html'] = programming_lang #Need to find a way to separate typescript file
    when 'react_jsx'
      paths['App.jsx'] = programming_lang
    when 'react_tsx'
      paths['App.tsx'] = programming_lang
      # Add more programming languages as needed
    end

    # Handle style languages
    case style_lang
    when 'css'
      paths['styles.css'] = style_lang
    when 'sass'
      paths['styles.sass'] = style_lang
    when 'tailwindcss'
      paths['tailwind.css'] = style_lang
      # Add more style languages as needed
    end

    paths
  end
  # Extracts content for each language from the response
  def self.extract_content_for_language(content, lang)
    case lang
    when 'html', 'html+javascript', 'html+typescript'
      content.match(/```html\n(.+?)```/m)[1].strip if content.include?('```html')
      content.match(/```typescript\n(.+?)```/m)[1].strip if content.include?('```typescript')
      content.match(/```javascript\n(.+?)```/m)[1].strip if content.include?('```javascript')
    when 'react_jsx'
      content.match(/```jsx\n(.+?)```/m)[1].strip if content.include?('```jsx')
    when 'react_tsx'
      content.match(/```tsx\n(.+?)```/m)[1].strip if content.include?('```jsx')
    when 'css'
      content.match(/```css\n(.+?)```/m)[1].strip if content.include?('```css')
    when 'sass'
      content.match(/```sass\n(.+?)```/m)[1].strip if content.include?('```sass')
    when 'tailwindcss'
      content.match(/```css\n(.+?)```/m)[1].strip if content.include?('```css') # Tailwind CSS goes in a CSS file
    else
      nil
    end
  end
end