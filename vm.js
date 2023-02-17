
class VirtualMachine {
    constructor(canvas) {
        this.data_stack      = new Int32Array(16);
        this.ds_ndx          = -1;
        this.return_stack    = new Int32Array(16);
        this.rs_ndx          = -1;
        this.buffer          = new ArrayBuffer(1024 * 64 * 4);
        this.code            = new Int32Array(this.buffer);
        this.program_counter = -1|0;
        this.code[2]         =  4; // code pointer 
        this.canvas          = document.getElementById(canvas);
        this.ctx             = this.canvas.getContext('2d');
        this.imagedata       = this.ctx.createImageData(640, 480);
        this.key             = -1;
        this.draw_count      = 0;
        this.running         = false;
        this.need_refresh    = false;
    }
    push_code(val) {this.code[this.code[2]++] = val;}
    CONTINUE(t_frame) { this.draw_count++; if(!this.running){this.Run(this.program_counter);} }
    Run (location) {
        this.program_counter = location;
        this.running = true;
        while (this.program_counter != -1) { // ABORT 
            switch(this.code[this.program_counter]) {
                case 0: // NOP
                    break;
                case 1: // LIT
                    this.data_stack[++this.ds_ndx] = this.code[++this.program_counter];
                    break;
                case 2: // CALL 
                    this.return_stack[++this.rs_ndx] = ++this.program_counter;
                    this.program_counter = this.code[this.program_counter];
                    continue;
                case 3: // RETURN
                    this.program_counter = this.rs_ndx === -1 ? -2 : this.return_stack[this.rs_ndx--]; 
                    break;
                case 4: // LOAD
                    this.data_stack[this.ds_ndx] = this.code[this.data_stack[this.ds_ndx]];
                    break;
                case 5: // STORE 
                    this.code[this.data_stack[this.ds_ndx--]] = this.data_stack[this.ds_ndx--];
                    break;
                case 6: // ADD 
                    this.data_stack[--this.ds_ndx] = (this.data_stack[this.ds_ndx+1] + this.data_stack[this.ds_ndx]);
                    break;
                case 7: // SUB 
                    this.data_stack[--this.ds_ndx] = this.data_stack[this.ds_ndx] - this.data_stack[this.ds_ndx+1];
                    break;
                case 8: // MUL 
                    this.data_stack[--this.ds_ndx] = this.data_stack[this.ds_ndx+1] * this.data_stack[this.ds_ndx];
                    break;
                case 9: // DIV 
                    this.data_stack[--this.ds_ndx] = this.data_stack[this.ds_ndx] / this.data_stack[this.ds_ndx+1];
                    break;
                case 10: // MOD 
                    this.data_stack[--this.ds_ndx] = this.data_stack[this.ds_ndx] % this.data_stack[this.ds_ndx+1];
                    break;
                case 11: // AND
                    this.data_stack[--this.ds_ndx] = this.data_stack[this.ds_ndx+1] & this.data_stack[this.ds_ndx];
                    break;
                case 12: // OR 
                    this.data_stack[--this.ds_ndx] = this.data_stack[this.ds_ndx+1] | this.data_stack[this.ds_ndx];
                    break;
                case 13: // NOT 
                    this.data_stack[this.ds_ndx] = ~this.data_stack[this.ds_ndx];
                    break;
                case 14: // DUP 
                    this.data_stack[++this.ds_ndx] = this.data_stack[this.ds_ndx-1];
                    break;
                case 15: // DROP 
                    this.ds_ndx--;
                    break;
                case 16: // SWAP 
                {   let tos = this.data_stack[this.ds_ndx];
                    this.data_stack[this.ds_ndx] = this.data_stack[this.ds_ndx - 1];
                    this.data_stack[this.ds_ndx - 1] = tos; }
                    break;
                case 17: // OVER
                    this.data_stack[++this.ds_ndx] = this.data_stack[this.ds_ndx - 2]; 
                    break;
                case 18: // TOR
                    this.return_stack[++this.rs_ndx] = this.data_stack[this.ds_ndx--]; 
                    break;
                case 19: // FROMR 
                    this.data_stack[++this.ds_ndx] = this.return_stack[this.rs_ndx--];
                    break;
                case 20: // JZ 
                    if(this.data_stack[this.ds_ndx--] == 0) { this.program_counter = this.code[this.program_counter+1]; }
                    else { this.program_counter+=2; }
                    continue;
                case 21: // JMP 
                    this.program_counter = this.code[this.program_counter+1];
                    continue;
                case 22: // GT 
                    if(this.data_stack[this.ds_ndx--] < this.data_stack[this.ds_ndx]) this.data_stack[this.ds_ndx] = -1; 
                    else this.data_stack[this.ds_ndx] = 0;
                    break;
                case 23: // EQ 
                    if(this.data_stack[this.ds_ndx--] == this.data_stack[this.ds_ndx]) this.data_stack[this.ds_ndx] = -1; 
                    else this.data_stack[this.ds_ndx] = 0;
                    break;
                case 24: // LT 
                    if(this.data_stack[this.ds_ndx--] > this.data_stack[this.ds_ndx]) this.data_stack[this.ds_ndx] = -1; 
                    else this.data_stack[this.ds_ndx] = 0;
                    break;
                case 25: // PUT_PIXEL
                {   let position = this.data_stack[this.ds_ndx--] * 4;
                    let value = this.data_stack[this.ds_ndx--];
                    this.imagedata.data[position++] = ((value >>> 16) & 0xFF); // red
                    this.imagedata.data[position++] = ((value >>> 8) & 0xFF);  // green
                    this.imagedata.data[position++] = (value & 0xFF);          // blue
                    this.imagedata.data[position]   = 0xFF;				
                    this.need_refresh = true; }
                    break;
                case 26: //DRAW_SCREEN 
                    if (this.need_refresh) {
                         this.ctx.putImageData(this.imagedata, 0, 0);
                         this.need_refresh = false; }
                    this.running = false;
		    this.program_counter++;
                    return;				
                case 27: // REFRESH_COUNT 
                    this.data_stack[++this.ds_ndx] = this.draw_count;
                    break;
                case 28: // READ_KEY
                    if(this.key == -1) { this.data_stack[++this.ds_ndx] = 0; }
                    else {
                        this.data_stack[++this.ds_ndx] = this.key;
                        this.data_stack[++this.ds_ndx] = 1;
                        this.key = -1; }
                    break;
                case 29: // LSHIFT 
                    this.data_stack[--this.ds_ndx] = this.data_stack[this.ds_ndx] << this.data_stack[this.ds_ndx+1];					
                    break;
                case 30: // RSHIFT 
                    this.data_stack[--this.ds_ndx] = this.data_stack[this.ds_ndx] >> this.data_stack[this.ds_ndx+1];	
                    break;
                case 31: // XOR 
                    this.data_stack[--this.ds_ndx] = this.data_stack[this.ds_ndx+1] ^ this.data_stack[this.ds_ndx];
                    break;
                default:
                    this.program_counter = -1; // ABORT 
                    continue;
            }
            this.program_counter++;
        }
        this.running = false;
        return this.program_counter;
    }
}
