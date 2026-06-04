use office_oxide::{Document, ir::*};
fn main() {
    let ir = Document::open("dart/test/fixtures/smoke.docx").unwrap().to_ir();
    let j = serde_json::to_string(&ir).unwrap();
    println!("len={}", j.len());
    if j.contains("image") { println!("has image tag"); }
    if j.contains("\"data\"") { println!("has data field"); }
}
