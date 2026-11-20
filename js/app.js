const links=[...document.querySelectorAll('[data-page]')],pages=[...document.querySelectorAll('.page')],heading=document.getElementById('heading'),sidebar=document.getElementById('sidebar'),toast=document.getElementById('toast');
function go(id){pages.forEach(p=>p.classList.toggle('active',p.id===id));links.forEach(a=>a.classList.toggle('active',a.dataset.page===id));const a=links.find(x=>x.dataset.page===id);heading.textContent=a?a.textContent.trim():'Panel principal';sidebar.classList.remove('open');location.hash=id}
links.forEach(a=>a.addEventListener('click',e=>{e.preventDefault();go(a.dataset.page)}));
document.getElementById('menu').addEventListener('click',()=>sidebar.classList.toggle('open'));
function notify(msg){toast.textContent=msg;toast.classList.add('show');setTimeout(()=>toast.classList.remove('show'),2600)}
document.querySelectorAll('[data-demo]').forEach(b=>b.addEventListener('click',()=>notify('Formulario de '+b.dataset.demo+' pendiente de conectar al backend.')));
document.querySelectorAll('[data-qr]').forEach(b=>b.addEventListener('click',()=>notify('Pasaporte digital '+b.dataset.qr+': módulo QR por implementar.')));
document.getElementById('print').addEventListener('click',()=>print());
const initial=location.hash.slice(1);if(initial&&document.getElementById(initial))go(initial);