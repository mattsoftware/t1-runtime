console.log('1..6');

var arr = [1, 2, 3, 1, 2, 3];

console.log('#', arr.indexOf(2));
console.log(arr.indexOf(2) == 1 ? 'ok' : 'not ok');

console.log('#', arr.indexOf(2, 0));
console.log(arr.indexOf(2, 0) == 1 ? 'ok' : 'not ok');

console.log('#', arr.indexOf(2, 1));
console.log(arr.indexOf(2, 1) == 1 ? 'ok' : 'not ok');

console.log('#', arr.indexOf(2, 2));
console.log(arr.indexOf(2, 2) == 4 ? 'ok' : 'not ok');

console.log('#', arr.indexOf(2, 4));
console.log(arr.indexOf(2, 4) == 4 ? 'ok' : 'not ok');

console.log('#', arr.indexOf(2, 5));
console.log(arr.indexOf(2, 5) == -1 ? 'ok' : 'not ok');
