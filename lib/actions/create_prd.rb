module Actions
  class CreatePrd < Action
    def call
      prd = params["prd"]
      file_manager.create_file("./prd.md", prd)
      output = 'success'
    end
  end
end
