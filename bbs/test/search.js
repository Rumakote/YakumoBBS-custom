const all_boards = document.getElementsByName('board');
const all_threads = document.getElementsByName('thread');

document.addEventListener('DOMContentLoaded',function(){
    let select_all = document.getElementById('select-all');
    select_all.addEventListener('click', selectall);

    for (let i=0;i<all_boards.length;i++){
	all_boards[i].addEventListener('click', board_select);
    }
    for (let i=0;i<all_threads.length;i++){
	all_threads[i].addEventListener('click', thread_select);
    }
});

function selectall(event){
    for (let i=0;i<all_boards.length;i++) {
	all_boards[i].checked = event.target.checked;
    }
    for (let i=0;i<all_threads.length;i++) {
	all_threads[i].checked = event.target.checked;
    }
}

function board_select(event){
    let child_threads = event.target.parentNode.getElementsByTagName('input');
    let select_all = document.getElementById('select-all');

    for (let i=0;i<child_threads.length;i++) {
	child_threads[i].checked = event.target.checked;
    }
    for (let i=0;i<all_boards.length;i++) {
	if(!all_boards[i].checked) {
	    select_all.checked = false;
	    break;
	}
	select_all.checked = true;
    }
}
function thread_select(event){
    let parent_board = event.target.parentNode.parentNode.parentNode.firstChild;
    let sibling_threads = event.target.parentNode.parentNode.getElementsByTagName('input');
    let select_all = document.getElementById('select-all');

    for (let i=0;i<sibling_threads.length;i++) {
	if(!sibling_threads[i].checked){
	    parent_board.checked = false;
	    break;
	}
	parent_board.checked = true;
    }
    
    for (let i=0;i<all_threads.length;i++) {
	if(!all_threads[i].checked){
	    select_all.checked = false;
	    break;
	}
	select_all.checked = true;
    }
}

