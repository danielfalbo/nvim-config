-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Convert double dash to em dash
vim.cmd([[iabbrev -- —]])
