
using Gadfly
using Colors


# inspired by BBC plot style, documented in: https://bbc.github.io/rcookbook/#how_to_create_bbc_style_graphics
# (repo: https://github.com/bbc/bbplot)
function plot_style()
    Theme(
        plot_padding=[4mm, 4mm, 9mm, 9mm],
        bar_spacing=1mm,
        boxplot_spacing=1mm,
        background_color=colorant"white",
        panel_fill=colorant"white",

        guide_title_position=:left,
        key_position=:top,
        key_title_font_size=12pt,
        key_title_color=colorant"#222222",
        key_label_font_size=12pt,
        key_label_color=colorant"#222222",     
        key_max_columns=6,

        major_label_font_size=13pt,
        major_label_color=colorant"#222222",
        
        minor_label_font_size=11pt,
        minor_label_color=colorant"#222222",
        
        point_label_font_size=10pt,
        point_label_color=colorant"#222222",
        
        grid_color=colorant"#cbcbcb"
    )
end