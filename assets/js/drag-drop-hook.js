import Sortable from "sortablejs";

const Hook = {
    mounted(){
        const s = Sortable.create(this.el, {
            group: "draggable",
            ghostClass: "bg-red-700",
            dragClass: "bg-cyan-800"
        });
        console.log(`sortable created for ${this.el.id}`)
    }
}

export default Hook;