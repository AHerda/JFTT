use std::{
    env::args,
    fs::read_to_string,
    cmp::min
};
use unicode_segmentation::UnicodeSegmentation;

fn main() {
    let args: Vec<String> = args().collect();

    let pattern = args[1].clone();
    let text = read_to_string(args[2].clone()).expect("Not able to read this file");

    let matches = seek_patterns(pattern, text);

    println!("{:?}", matches);

    // let s = "नमस्ते";
    // let m = s.graphemes(true).collect::<Vec<&str>>();
}

fn seek_patterns(pattern_string: String, text_string: String) -> Vec<usize> {
    let pattern = pattern_string.graphemes(true).collect::<Vec<&str>>();
    let text = text_string.graphemes(true).collect::<Vec<&str>>();
    let m = pattern.len();
    let _n = text.len();
    let d = build_d(&pattern);
    let mut q = 0;
    let mut matches: Vec<usize> = vec![];

    text
        .iter()
        .enumerate()
        .for_each(|(i, grapheme)| {
            let grapheme_index = pattern.iter().position(|x| x == grapheme).unwrap_or_else(|| { println!("Que the fuck?!?!"); 0 });
        
            q = d[q][grapheme_index];
            if q == m {
                matches.push(i - m + 1);
            }
        });
    matches
}

fn build_d(pattern: &Vec<&str>) -> Vec<Vec<usize>> {
    let m = pattern.len();
    let mut d =  vec![vec![0; m]; m + 1];

    for q in 0..=m {
        for &grapheme in pattern {
            let mut k = min(m, q + 1);
            while k > 0 {
                k -= 1;
                let mut temp = pattern[..k].to_vec();
                temp.push(grapheme);
                if temp == pattern[q - k..q].to_vec() {
                    break;
                }
            }
            d[q][pattern.iter().position(|&x| x == grapheme).unwrap()] = k;
        }
    }

    vec![vec![0; m]; m + 1]
}