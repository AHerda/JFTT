use comfy_table::Table;
use std::{
    cmp::{max, min},
    env::args,
    fs::read_to_string,
    process,
};
use unicode_segmentation::UnicodeSegmentation;

fn main() {
    let args: Vec<String> = args().collect();
    if args.len() != 3 {
        eprintln!("Error\nWrong enaugh arguments");
        process::exit(1);
    }

    let binding = args[1].clone();
    let pattern = binding.graphemes(true).collect::<Vec<&str>>();
    let binding = read_to_string(args[2].clone()).expect("Not able to read this file");
    let text = binding.graphemes(true).collect::<Vec<&str>>();

    let matches = seek_patterns(&pattern, &text);

    let mut table = Table::new();
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

    println!("{table}");
}

fn seek_patterns(pattern: &[&str], text: &[&str]) -> Vec<usize> {
    let m = pattern.len();
    let d = build_d(pattern);
    let mut q = 0;
    let mut matches: Vec<usize> = Vec::new();

    text.iter().enumerate().for_each(|(i, grapheme)| {
        let grapheme_index = pattern
            .iter()
            .position(|x| x == grapheme);

        q = match grapheme_index {
            Some(i) => d[q][i],
            None => 0,
        };
        if q == m {
            matches.push(i + 1 - m);
        }
    });
    matches
}

fn build_d(pattern: &[&str]) -> Vec<Vec<usize>> {
    let m = pattern.len();
    let mut d = vec![vec![0; m]; m + 1];

    for q in 0..=m {
        pattern.iter().enumerate().for_each(|(i, &grapheme)| {
            let mut k = min(m, q + 1);
            while k > 0 {
                let mut temp = pattern[..q].to_vec();
                temp.push(grapheme);
                if pattern[..k].to_vec() == temp[temp.len() - k..].to_vec() {
                    break;
                }
                k -= 1;
            }
            d[q][i] = k;
        });
    }
    // println!("{:#?}", d);
    d
}
