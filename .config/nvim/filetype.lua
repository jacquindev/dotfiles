if not vim.filetype then return end

vim.filetype.add({
  pattern = {
    [".*/playbooks/.*%.yaml"] = "yaml.ansible",
    [".*/playbooks/.*%.yml"] = "yaml.ansible",
    [".*/roles/.*/tasks/.*%.yaml"] = "yaml.ansible",
    [".*/roles/.*/tasks/.*%.yml"] = "yaml.ansible",
    [".*/tasks/.*%.yaml"] = "yaml.ansible",
    [".*/tasks/.*%.yml"] = "yaml.ansible",
    [".*/vars/.*%.yaml"] = "yaml.ansible",
    [".*/vars/.*%.yml"] = "yaml.ansible",
    [".*/defaults/.*%.yaml"] = "yaml.ansible",
    [".*/defaults/.*%.yml"] = "yaml.ansible",
    [".*/handlers/.*%.yaml"] = "yaml.ansible",
    [".*/handlers/.*%.yml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.yaml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.yml"] = "yaml.ansible",
		['.*%.conf'] = 'conf',
    ['.*%.theme'] = 'conf',
    ['.*%.gradle'] = 'groovy',
    ['^.env%..*'] = 'bash',
  },
	filename = {
    ['NEOGIT_COMMIT_EDITMSG'] = 'NeogitCommitMessage',
    ['.psqlrc'] = 'conf',
    ['launch.json'] = 'jsonc',
    Podfile = 'ruby',
    Brewfile = 'ruby',
  },
})
