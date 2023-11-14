use unicode_segmentation::UnicodeSegmentation;

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
    let mut pi: Vec<usize> = vec![0; m];
    let mut k = 0;

    for q in 1..m {
        while k > 0 && pattern[k] != pattern[q] {
            k = pi[k - 1];
        }
        if pattern[k] == pattern[q] {
            k += 1;
        }
        pi[q] = k;
    }

    pi
}
