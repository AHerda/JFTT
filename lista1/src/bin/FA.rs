use std::cmp::min;
use unicode_segmentation::UnicodeSegmentation;
use std::collections::HashSet;

use lista1::{get_args, table};

fn main() {
    let (pattern_str, text_str): (String, String) = get_args();
    let pattern = pattern_str.graphemes(true).collect::<Vec<&str>>();
    let text = text_str.graphemes(true).collect::<Vec<&str>>();

    let matches = seek_patterns(&pattern, &text);

    table(matches, pattern, text);
}

fn seek_patterns(pattern: &[&str], text: &[&str]) -> Vec<usize> {
    let m = pattern.len();
    let d = build_d(pattern);
    let mut q = 0;
    let mut matches: Vec<usize> = Vec::new();

    text.iter().enumerate().for_each(|(i, grapheme)| {
        let grapheme_index = pattern.iter().position(|x| x == grapheme);
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
    println!("{d:?}");
    d
}
