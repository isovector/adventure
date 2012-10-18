if not MOAIFileSystem.copy then
    function MOAIFileSystem.copy(src, dest)
        -- don't expect THIS to work on windows :)
        os.execute(string.format("cp -r %q %q", src, dest))
    end
end
