# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../app/services/file_generation_service'
class GenerationTest < Minitest::Test
  def setup
    @project_location = "storage/JaniHegedus/Projects/First Project"
    @response =   {
      "id"=>"chatcmpl-98UwoIogOx3dpp1Lv7HvEin7n8BCJ",
                   "object"=>"chat.completion",
                   "created"=>1711812614,
                   "model"=>"gpt-4-1106-vision-preview",
                   "choices"=>[
                     {"index"=>0,
                      "message"=>
                        {
                          "role"=>"assistant",
                          "content"=>
                            "To create a webpage with React and Tailwind CSS that includes this image and the text as seen in the image, here's a basic example. Before you use the following code, ensure you have `create-react-app` installed and you've set up Tailwind CSS in your React project.\n\n1. First, create a new React component, let's say `HomePage.js`:\n\n```jsx\nimport React from 'react';\nimport myImage from './path-to-image.jpg'; // Make sure to import the image and set the correct path\n\nconst HomePage = () => {\n  return (\n    <div className=\"flex justify-center items-center h-screen bg-gray-100\">\n      <div className=\"max-w-sm rounded overflow-hidden shadow-lg\">\n        <img className=\"w-full\" src={myImage} alt=\"Character\"/>\n        <div className=\"px-6 py-4\">\n          <div className=\"font-bold text-xl mb-2\">Home Page</div>\n        </div>\n        <div className=\"px-6 pt-4 pb-2\">\n          <span className=\"inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2\">JaniHegedus</span>\n        </div>\n      </div>\n    </div>\n  );\n};\n\nexport default HomePage;\n```\n\n2. Then, in your `App.js`, you can use this component:\n\n```jsx\nimport React from 'react';\nimport HomePage from './HomePage'; // Import the HomePage component\n\nfunction App() {\n  return (\n    // Use the HomePage component\n    <HomePage />\n  );\n}\n\nexport default App;\n```\n\n3. For the Tailwind setup, ensure your `tailwind.config.js` allows for the necessary customization:\n\n```js\nmodule.exports = {\n  // ...\n  theme: {\n    extend: {\n      // Add custom colors, spacing, or any other Tailwind configuration you need.\n    },\n  },\n  // ...\n};\n```\n\n4. Lastly, ensure you have imported the Tailwind CSS file in your `index.css`:\n\n```css\n@import 'tailwindcss/base';\n@import 'tailwindcss/components';\n@import 'tailwindcss/utilities';\n```\n\nNow, when you run your React application with `npm start` or `yarn start`, you should see a web page that visually resembles the information you provided in the image. Adjust the Tailwind CSS classes as needed to match the styling you desire."},
                      "logprobs"=>nil,
                      "finish_reason"=>"stop"}],
                   "usage"=>{"prompt_tokens"=>809,
                             "completion_tokens"=>510, "total_tokens"=>1319},
                   "system_fingerprint" =>nil
    }
    @languages = {"programming"=>"react_jsx", "style"=>"tailwindcss"}
  end

  def test_file_generation
    FileGenerationService.generate_files(@project_location, @response["choices"][0]["message"]["content"], @languages)
    react_jsx_exists = File.exist?(File.join(@project_location, 'App.jsx'))
    ai_file_exists = File.exist?(File.join(@project_location, 'Ai_Response.txt'))
    tailwind_css_exists = File.exist?(File.join(@project_location, 'tailwind.css'))

    assert(react_jsx_exists, "The React JSX file was not created.")
    assert(tailwind_css_exists, "The Tailwind CSS file was not created.")
    assert(ai_file_exists, "The AI file was not created.")
  end

  def teardown
    # Cleanup - Remove the files and directory after test run
    FileUtils.remove_dir(@project_location, force: true)
  end
end
