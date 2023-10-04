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
    let pi = build_pi(pattern);
    let mut q = 0;

    let mut matches: Vec<usize> = Vec::new();

    text.iter().enumerate().for_each(|(i, &graphene)| {
        while q > 0 && pattern[q] != graphene {
            q = pi[q - 1];
        }
        if pattern[q] == graphene {
            q += 1;
        }
        if q == m {
            matches.push(i + 1 - m);
            q = pi[q - 1];
        }
    });

    matches
}

fn build_pi(pattern: &[&str]) -> Vec<usize> {
    let m = pattern.len();
    let mut k = 0;
    let mut pi: Vec<usize> = vec![0; m];

    for q in 1..m {
        while k > 0 && pattern[k] != pattern[q] {
            k = pi[k - 1];
        }
        if pattern[q] == pattern[k] {
            k += 1;
        }
        pi[q] = k;
    }

    pi
}
