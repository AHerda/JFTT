use comfy_table::{
    modifiers::UTF8_ROUND_CORNERS, presets::UTF8_FULL, CellAlignment, ContentArrangement, Table,
};
use std::{
    cmp::{max, min},
    env::args,
    fs::read_to_string,
    process,
};

pub fn get_args() -> (String, String) {
    let args: Vec<String> = args().collect();
    if args.len() != 3 {
        eprintln!("Error\nWrong enaugh arguments");
        process::exit(1);
    }

    let pattern = args[1].clone();
    let text = read_to_string(&args[2]).expect("Not able to read this file");

    (pattern, text)
}

pub fn table(matches: Vec<usize>, pattern: Vec<&str>, text: Vec<&str>) {
    let mut table = Table::new();
    table
        .load_preset(UTF8_FULL)
        .apply_modifier(UTF8_ROUND_CORNERS)
        .set_content_arrangement(ContentArrangement::Dynamic);

    table.set_header(vec!["column", "proximity"]);

    matches.iter().for_each(|i| {
        let i_i32: i32 = *i as i32;
        table.add_row(vec![
            format!("{i}"),
            format!(
                "{:?}",
                text[usize::from(max(0, i_i32 - 1) as u16)..min(i + pattern.len() + 1, text.len())]
                    .to_vec()
            ),
        ]);
    });

    table
        .column_iter_mut()
        .for_each(|column| column.set_cell_alignment(CellAlignment::Center));

    println!("{table}");
}
