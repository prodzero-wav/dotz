function fish_prompt
    set_color 6f9f8b
    echo -n $USER
    set_color d4cba8
    echo -n " "(prompt_pwd)
    set_color normal
    echo -n " ▸ "
end
